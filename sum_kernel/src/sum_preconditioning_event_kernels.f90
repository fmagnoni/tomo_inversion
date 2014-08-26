program sum_preconditioned_kernels

  implicit none
  include 'mpif.h'
  include 'constants.h'
  include 'precision.h'

  ! ======================================================

  !----------------------------------------------------------------------------------------
  ! USER PARAMETER
  ! 1 permille of maximum for inverting hessian
  real(kind=CUSTOM_REAL),parameter :: THRESHOLD_HESS = 1.e-3
  ! sums all hessians before inverting and preconditioning
  logical, parameter :: USE_HESS_SUM = .true.
  !----------------------------------------------------------------------------------------

  integer :: NSPEC

  character(len=150) :: kernel_file_list, kernel_list(1000), sline, k_file, kernel_name, ftagfile, ftag
  character(len=256) :: prname_lp
  real(kind=CUSTOM_REAL), dimension(:,:,:,:),allocatable :: kernel,total_kernel
  real(kind=CUSTOM_REAL), dimension(:,:,:,:),allocatable :: hess,total_hess
  integer :: iker, nker, myrank, sizeprocs, ier
  integer :: i, j, k,ispec, iglob, ishell, n, it, j1, ib, npts_sem, ios

  ! ============ program starts here =====================
  ! initialize the MPI communicator and start the NPROCTOT MPI processes
  call MPI_INIT(ier)
  call MPI_COMM_SIZE(MPI_COMM_WORLD,sizeprocs,ier)
  call MPI_COMM_RANK(MPI_COMM_WORLD,myrank,ier)

  kernel_file_list='kernels_run_italy'  !magnoni
  ftagfile = 'ftags'

  ! read in the list of event IDs
  nker=0
  open(unit = 20, file = trim(kernel_file_list), status = 'old',iostat = ios)
  if (ios /= 0) then
     print *,'Error opening ',trim(kernel_file_list)
     stop
  endif
  do while (1 == 1)
     read(20,'(a)',iostat=ios) sline
     if (ios /= 0) exit
     nker=nker+1
     kernel_list(nker) = sline
  enddo
  close(20)

  ! read in the name of the kernel
  open(unit = 20, file = trim(ftagfile), status = 'old',iostat = ios)
  if (ios /= 0) then
     print *,'Error opening ',trim(ftagfile)
     stop
  endif
  read(20,'(a)',iostat=ios) ftag
  if (ios /= 0) then
     print *,'Error reading ',trim(ftagfile)
     stop
  endif
  close(20)

  !for each proc read the number of spectral element
  !write(prname_lp,'(a,i6.6,a)') 'INPUT_KERNELS/'//trim(kernel_list(iker))//'/proc',myrank,'_'
  write(prname_lp,'(a,i6.6,a)') 'INPUT_KERNELS/proc',myrank,'_'
  open(unit=27,file=prname_lp(1:len_trim(prname_lp))//'external_mesh.bin',status='old',action='read',form='unformatted',iostat=ios)
  read(27) NSPEC
  close(27) !magnoni
  
  allocate(kernel(NGLLX,NGLLY,NGLLZ,NSPEC))
  allocate(total_kernel(NGLLX,NGLLY,NGLLZ,NSPEC))
  total_kernel(:,:,:,:) = 0.0_CUSTOM_REAL
  kernel(:,:,:,:) = 0.0_CUSTOM_REAL
  
  allocate(hess(NGLLX,NGLLY,NGLLZ,NSPEC))
  allocate(total_hess(NGLLX,NGLLY,NGLLZ,NSPEC))
  total_hess(:,:,:,:) = 0.0_CUSTOM_REAL
  hess(:,:,:,:) = 0.0_CUSTOM_REAL
  

  kernel_name = ftag

!   total_kernel=0.
  do iker = 1, nker
     if(myrank==1) write(*,*) 'reading in event kernel: ', iker, ' out of ', nker  !magnoni: reso più generale per ogni tipo di kernel
     write(k_file,'(a,i6.6,a)') 'INPUT_KERNELS/'//trim(kernel_list(iker))//'/proc',myrank,'_'//trim(kernel_name)//'.bin'
     open(12,file=trim(k_file),status='old',form='unformatted',action='read',iostat=ios) !magnoni: cambiato
     if( ios /= 0 ) then																 !magnoni: aggiunto
       write(*,*) '  kernel not found:',trim(k_file)
       cycle
     endif
     read(12) kernel(:,:,:,1:NSPEC)
     close(12)

     ! approximate Hessian
     write(k_file,'(a,i6.6,a)') 'INPUT_KERNELS/'//trim(kernel_list(iker))//'/proc',myrank,'_hess_kernel.bin'
     open(12,file=trim(k_file),status='old',form='unformatted',action='read',iostat=ios)
     if( ios /= 0 ) then
       write(*,*) '  hess not found:',trim(k_file)
       cycle
     endif
     read(12) hess
     close(12)
     
     ! note: we take absolute values for hessian (as proposed by Yang)
     hess = abs(hess)

     if( USE_HESS_SUM ) then
       ! sums up hessians first
       total_hess = total_hess + hess
     else
       ! inverts hessian
       call invert_hess( myrank,hess,THRESHOLD_HESS,NSPEC )
       ! preconditions each event kernel with its hessian
       kernel = kernel* hess
     endif

     ! sums all kernels from each event
     total_kernel(:,:,:,1:NSPEC) = total_kernel(:,:,:,1:NSPEC) + kernel(:,:,:,1:NSPEC)

  enddo

  ! preconditions summed kernels with summed hessians  
  if( USE_HESS_SUM ) then
      ! inverts hessian matrix
      call invert_hess( myrank,total_hess,THRESHOLD_HESS,NSPEC )
      ! preconditions kernel
      total_kernel = total_kernel * total_hess
  endif
  
  ! stores summed kernels  
  if(myrank==1) write(*,*) 'writing out summed preconditioned kernel'   !magnoni: per sottolineare che fa precon
  write(k_file,'(a,i6.6,a)') 'OUTPUT_SUM/proc',myrank,'_'//trim(kernel_name)//'.bin'
  open(12,file=trim(k_file),form='unformatted',status='unknown',action='write',iostat=ios)
  if( ios /= 0 ) then
    write(*,*) 'ERROR kernel not written:',trim(k_file)
    stop 'error kernel write'
  endif
  write(12) total_kernel(:,:,:,1:NSPEC)
  close(12)


  if(myrank==1) write(*,*) 'done writing all kernels, now finishing...'

  ! stop all the MPI processes, and exit
  call MPI_FINALIZE(ier)

  deallocate(kernel) !magnoni
  deallocate(total_kernel) !magnoni
  deallocate(total_hess) !magnoni
  deallocate(hess) !magnoni

end program sum_preconditioned_kernels

!
!-------------------------------------------------------------------------------------------------
!


subroutine invert_hess( myrank,hess_matrix,THRESHOLD_HESS,NSPEC)

! inverts the hessian matrix
! the approximate hessian is only defined for diagonal elements: like
! H_nn = \frac{ \partial^2 \chi }{ \partial \rho_n \partial \rho_n }
! on all GLL points, which are indexed (i,j,k,ispec)
  
    implicit none
    include 'mpif.h'
    include 'constants.h'
    include 'precision.h'

  integer :: myrank, NSPEC
  real(kind=CUSTOM_REAL), dimension(NGLLX,NGLLY,NGLLZ,NSPEC) :: hess_matrix
  real(kind=CUSTOM_REAL) :: THRESHOLD_HESS

  ! local parameters
  real(kind=CUSTOM_REAL) :: maxh,maxh_all
  integer :: ier
  
  ! maximum value of hessian
  maxh = maxval( abs(hess_matrix) )

  ! determines maximum from all slices on master
  call mpi_allreduce(maxh,maxh_all,1,CUSTOM_MPI_TYPE,MPI_MAX,MPI_COMM_WORLD,ier)
  if( maxh_all < 1.e-18 ) then
    ! threshold limit of hessian
    call exit_mpi(myrank,'error hessian too small')
  endif
  
  ! normalizes hessian 
  ! since hessian has absolute values, this scales between [0,1]
  hess_matrix = hess_matrix / maxh_all

  ! inverts hessian values
  where( abs(hess_matrix(:,:,:,:)) > THRESHOLD_HESS )
    hess_matrix = 1.0_CUSTOM_REAL / hess_matrix
  elsewhere
    hess_matrix = 1.0_CUSTOM_REAL / THRESHOLD_HESS
  endwhere

  ! rescales hessian
  !hess_matrix = hess_matrix * maxh_all
  
end subroutine invert_hess

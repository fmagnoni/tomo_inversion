program sum_kernels

  implicit none
  include 'mpif.h'
  include 'constants.h'
  include 'precision.h'

  ! ======================================================

  integer :: NSPEC

  character(len=150) :: kernel_file_list, kernel_list(1000), sline, k_file, kernel_name, ftagfile, ftag
  character(len=256) :: prname_lp
  real(kind=CUSTOM_REAL), dimension(:,:,:,:),allocatable :: kernel, total_kernel
  integer :: iker, nker, myrank, sizeprocs,  ier
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
  allocate(kernel(NGLLX,NGLLY,NGLLZ,NSPEC))
  allocate(total_kernel(NGLLX,NGLLY,NGLLZ,NSPEC))

  kernel_name = ftag

  total_kernel=0.
  do iker = 1, nker
     if(myrank==1) write(*,*) 'reading in event kernel: ', iker, ' out of ', nker  !magnoni: reso più generale per ogni tipo di kernel
     write(k_file,'(a,i6.6,a)') 'INPUT_KERNELS/'//trim(kernel_list(iker))//'/proc',myrank,'_'//trim(kernel_name)//'.bin'
     open(12,file=trim(k_file),status='old',form='unformatted')
     read(12) kernel(:,:,:,1:NSPEC)
     close(12)

     total_kernel(:,:,:,1:NSPEC) = total_kernel(:,:,:,1:NSPEC) + kernel(:,:,:,1:NSPEC)

  enddo
  if(myrank==1) write(*,*) 'writing out summed kernel'   !magnoni: reso più generale per ogni tipo di kernel
  write(k_file,'(a,i6.6,a)') 'OUTPUT_SUM/proc',myrank,'_'//trim(kernel_name)//'.bin'
  open(12,file=trim(k_file),form='unformatted',status='unknown')
  write(12) total_kernel(:,:,:,1:NSPEC)
  close(12)


  if(myrank==1) write(*,*) 'done writing all kernels, now finishing...'

  ! stop all the MPI processes, and exit
  call MPI_FINALIZE(ier)

  deallocate(kernel) !magnoni
  deallocate(total_kernel) !magnoni
  close(27) !magnoni

end program sum_kernels



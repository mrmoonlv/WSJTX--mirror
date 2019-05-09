subroutine extractmessage174_91(decoded,msgreceived,ncrcflag)
  use iso_c_binding, only: c_loc,c_size_t
  use crc
  use packjt

  character*22 msgreceived
  character*91 cbits
  integer*1 decoded(91)
  integer*1, target::  i1Dec8BitBytes(12)
  integer*4 i4Dec6BitWords(12)

! Write decoded bits into cbits: 77-bit message plus 14-bit CRC
  write(cbits,1000) decoded
1000 format(91i1)
  read(cbits,1001) i1Dec8BitBytes
1001 format(12b8)
  read(cbits,1002) ncrc14                         !Received CRC12
1002 format(77x,b14)

  i1Dec8BitBytes(10)=iand(i1Dec8BitBytes(10),transfer(128+64+32+16+8,0_1))
  i1Dec8BitBytes(11:12)=0
  icrc14=crc14(c_loc(i1Dec8BitBytes),12)          !CRC12 computed from 75 msg bits

  if(ncrc14.eq.icrc14 .or. sum(decoded(57:87)).eq.0) then  !### Kludge ###
! CRC14 checks out --- unpack 72-bit message
    do ibyte=1,12
      itmp=0
      do ibit=1,6
        itmp=ishft(itmp,1)+iand(1_1,decoded((ibyte-1)*6+ibit))
      enddo
      i4Dec6BitWords(ibyte)=itmp
    enddo
    call unpackmsg(i4Dec6BitWords,msgreceived)
    ncrcflag=1
  else
    msgreceived=' '
    ncrcflag=-1
  endif 
  return
  end subroutine extractmessage174_91

 #!/bin/bash
 for dtb_file in `ls *.dtb`
 do
    echo $dtb_file
    dtc -I dtb -O dts $dtb_file -o "$(echo "$dtb_file" | sed -r 's|.dtb|.dts|g')"
 done
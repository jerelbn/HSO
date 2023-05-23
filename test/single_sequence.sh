# run single
#-------------------------

#change it to your images folder
pathImageFolder='/workspaces/HSO/datasets/kitti01' 


#change it to the corresponding camera file.
cameraCalibFile='./cameras/kitti.txt' 


./../bin/test_dataset image="$pathImageFolder" calib="$cameraCalibFile" #start=xxx end=xxx times=xxx name=xxx


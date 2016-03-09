
import cv2
import os
root_dir = "hmdb51/"

dirs = os.listdir("hmdb51/")
for dir_name in dirs:
    for vid_file in os.listdir(root_dir + dir_name):
        if vid_file.endswith(".avi"):
            #print vid_file
            vc = cv2.VideoCapture(root_dir + dir_name + '/' + vid_file)
            print vc.get(cv2.cv.CV_CAP_PROP_FRAME_COUNT)
            c = 1
            if not os.path.exists('temp/' + dir_name + '/' + vid_file):
                os.makedirs('temp/' + dir_name + '/' + vid_file)
            print (root_dir + dir_name + '/' + vid_file)
            flag = True
            # if vc.isOpened():
            #     rval, frame = vc.read()
            # else:
            #     rval = False
            # while rval:
            #     cv2.imwrite('temp/' + dir_name + '/' + vid_file + '/' + str(
            #         c) + '.jpg', frame)
            #     c += 1
            #     #cv2.waitKey(1)
            #     rval, frame = vc.read()
            while flag:
                if vc.grab():
                    flag, frame = vc.retrieve()
                    if flag:
                        cv2.imwrite('temp/' + dir_name + '/' + vid_file + '/' +
                                    str(c) + '.jpg', frame)
                        c += 1
                else:
                    flag = False
            vc.release()

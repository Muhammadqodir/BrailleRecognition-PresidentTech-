import PIL
print("Importing YOLO...")
from ultralytics import YOLO
from convert import convert_to_braille_unicode, parse_xywh_and_class
CONF = 0.15
MODEL_PATH = "./yolov8_braille.pt"
IMG = "/Users/mqodir/Documents/GitHub/BrailleRecognition/OpenData/Photo_Turlom_C2_6.jpeg"

def load_model(model_path):
    model = YOLO(model_path)
    return model

def load_image(image_path):
    image = PIL.Image.open(image_path)
    return image

print("Loading model...")
model = YOLO(MODEL_PATH)

def getAvgSpace(list_boxes):
    avg_space = 0
    count = 0
    for box_line in list_boxes:
        last_pos = box_line[0][0]
        for each_class in box_line:
            avg_space += each_class[0] - last_pos
            last_pos = each_class[0]
            count+=1
    return avg_space/count

def recognize(image_path):
    print("Starting recognition...")
    image = load_image(image_path)
    res = model.predict(image, save=True, save_txt=True, exist_ok=True, conf=CONF)
    print("Successful!")
    boxes = res[0].boxes
    list_boxes = parse_xywh_and_class(boxes)
    width, height = image.size
    final_img = PIL.Image.new('RGBA', (width,height), "black")
    result = ""
    avg_space = getAvgSpace(list_boxes)
    matrix = []
    for box_line in list_boxes:
        str_left_to_right = ""
        last_pos = box_line[0][0]
        line = []
        for each_class in box_line:
            item = []
            space = each_class[0] - last_pos
            last_pos = each_class[0]
            if space > avg_space:
                str_left_to_right += " "
            str_left_to_right += convert_to_braille_unicode(model.names[int(each_class[5])])
            item.extend(each_class)
            item.append(convert_to_braille_unicode(model.names[int(each_class[5])]))
            line.append(item)
        matrix.append(line)
        result += str_left_to_right + "\n"
    res = {}
    res["model"] = matrix
    res["text"] = result
    return res
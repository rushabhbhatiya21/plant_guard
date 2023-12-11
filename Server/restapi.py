from flask import Flask, json, request, jsonify, send_from_directory
from flask_cors import CORS

import os
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'

import urllib.request
from werkzeug.exceptions import HTTPException
from werkzeug.utils import secure_filename

import cv2
from pyzbar.pyzbar import decode
import base64

import glob
from tensorflow import keras
from PIL import Image
import numpy as np

app = Flask(__name__)

app.secret_key = "demirai112s2s1dsa*"

UPLOAD_FOLDER = r'C:\Users\Vikas\OneDrive\Desktop\CP-3\FINAL APP\uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg'])

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Define a function to preprocess the uploaded image
def preprocess_image(image_path):
    # Load the image
    img = Image.open(image_path)

    # Preprocess the image as needed for your model (e.g., resizing and normalization)
    img = img.resize((224, 224))  # Adjust to match your model's input size
    img = np.array(img) / 255.0  # Normalize pixel values

    return img

def load_model():
    # Load your machine learning model (replace 'model.h5' with your model file)
    model = keras.models.load_model(r'C:\Users\Vikas\OneDrive\Desktop\CP-3\FINAL APP\model.h5')
    return model

@app.route('/')
def main():
    return 'Homepage'

@app.route('/get')
def get():

    dirFiles = os.listdir(app.config['UPLOAD_FOLDER'])
    dirFiles.sort()
    file=dirFiles[len(dirFiles)-1]

    return send_from_directory(app.config["UPLOAD_FOLDER"], file, as_attachment=True)

@app.route('/get_all', methods=['GET'])
def get_all_images():
    image_files = os.listdir(app.config['UPLOAD_FOLDER'])
    image_files = [file for file in image_files if file.lower().endswith(('.jpg', '.jpeg', '.png'))]
    return jsonify({'image_files': image_files})

@app.route('/upload', methods=['POST'])
def upload_file():

    if 'files' not in request.files:
        resp = jsonify({'message' : 'No file part in the request'})
        resp.status_code = 400
        return resp

    files = request.files.getlist('files')
    errors = {}
    success = False

    for file in files:
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            success = True
        else:
            errors[file.filename] = 'File type is not allowed'

    if success and errors:

        errors['message'] = 'File(s) successfully uploaded'
        resp = jsonify(errors)
        resp.status_code = 500
        return resp

    if success:

        img = cv2.imread(os.path.join(app.config['UPLOAD_FOLDER'], filename))

        for barcode in decode(img):

            myData = barcode.data.decode('utf-8')
            pts = np.array([barcode.polygon],np.int32)
            pts = pts.reshape((-1,1,2))
            cv2.polylines(img,[pts],True,(255,0,255),2)
            pts2 = barcode.rect
            cv2.putText(img,myData,(pts2[0],pts2[1]),cv2.FONT_HERSHEY_SIMPLEX, 0.9,(255,0,255),2)


        cv2.imwrite(os.path.join(app.config['UPLOAD_FOLDER'], filename),img)
        resp=""
        with open(os.path.join(app.config['UPLOAD_FOLDER'], filename), "rb") as img_file:
            resp = base64.b64encode(img_file.read())

        return resp

    else:

        resp = jsonify(errors)
        resp.status_code = 500

        return resp
    
@app.route('/predict', methods=['GET'])
def predict_disease():
    try:
        # Load ML model
        model = load_model()
        print('model loaded')
        # Get the list of image files in the "uploads" folder
        image_files = glob.glob('uploads/*.jpg')

        if not image_files:
            return jsonify({'error': 'No image files found in the "uploads" folder'})

        # Sort the list by file modification time to get the latest image
        latest_image_path = max(image_files, key=os.path.getmtime)

        # Preprocess the image
        preprocessed_image = preprocess_image(latest_image_path)

        # Make predictions using your model
        predictions = model.predict(np.expand_dims(preprocessed_image, axis=0))

        # Extract the predicted class (disease)
        predicted_class = np.argmax(predictions, axis=1)

        # Convert the class index to a human-readable label
        # Generate disease labels for 38 diseases
        disease_labels = [
            'Apple___Apple_scab',
            'Apple___Black_rot',
            'Apple___Cedar_apple_rust',
            'Apple___healthy',
            'Blueberry___healthy',
            'Cherry_(including_sour)___healthy',
            'Cherry_(including_sour)___Powdery_mildew',
            'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
            'Corn_(maize)___Common_rust_',
            'Corn_(maize)___healthy',
            'Corn_(maize)___Northern_Leaf_Blight',
            'Grape___Black_rot',
            'Grape___Esca_(Black_Measles)',
            'Grape___healthy',
            'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
            'Orange___Haunglongbing_(Citrus_greening)',
            'Peach___Bacterial_spot',
            'Peach___healthy',
            'Pepper,_bell___Bacterial_spot',
            'Pepper,_bell___healthy',
            'Potato___Early_blight',
            'Potato___healthy',
            'Potato___Late_blight',
            'Raspberry___healthy',
            'Soybean___healthy',
            'Squash___Powdery_mildew',
            'Strawberry___healthy',
            'Strawberry___Leaf_scorch',
            'Tomato___Bacterial_spot',
            'Tomato___Early_blight',
            'Tomato___healthy',
            'Tomato___Late_blight',
            'Tomato___Leaf_Mold',
            'Tomato___Septoria_leaf_spot',
            'Tomato___Spider_mites Two-spotted_spider_mite',
            'Tomato___Target_Spot',
            'Tomato___Tomato_mosaic_virus',
            'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
            # Add your disease labels here
        ]

        predicted_disease = disease_labels[predicted_class[0]]

        print('predict: ',predicted_disease)
        return jsonify({'predicted_disease': predicted_disease})

    except Exception as e:
        return jsonify({'error': str(e)})
    
def page_not_found(e):
    # note that we set the 404 status explicitly
    return jsonify({"message from page_not_found": "Data not found! Exception:" + str(e)}), 404

@app.errorhandler(HTTPException)
def handle_exception(e):
    """Return JSON instead of HTML for HTTP errors."""
    # start with the correct headers and status code from the error
    response = e.get_response()
    # replace the body with JSON
    response.data = json.dumps({
        "code": e.code,
        "name": e.name,
        "description": e.description,
    })
    response.content_type = "application/json"
    return response


if __name__ == '__main__':
    CORS(app)
    from argparse import ArgumentParser
    parser = ArgumentParser()
    # # We add additional arguments which can be used during execution to perform
    # addition funtionality such as create a new port
    parser.add_argument('-p', '--port', type=int, default=5000)
    # Getting a list of arguments using parser
    args = parser.parse_args()
    port = args.port
    app.run(host='0.0.0.0', port=port, debug=True, ssl_context=None)
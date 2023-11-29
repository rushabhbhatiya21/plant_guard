import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator, load_img, img_to_array
from tensorflow.keras.applications import ResNet50
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras.models import Model

# Define the paths to your training and validation data directories
train_data_dir = r'D:\CP-III\New Plant Diseases Dataset(Augmented)\train'
validation_data_dir = r'D:\CP-III\New Plant Diseases Dataset(Augmented)\valid'
test_data_dir = r'D:\CP-III\test'
model_save_path = r'D:\CP-III\model.h5'

# Define image size, batch size and number of epochs
image_size = (224, 224)
batch_size = 32
num_epochs = 2

# Create an ImageDataGenerator for data augmentation and preprocessing
datagen = ImageDataGenerator(
    rescale=1./255  # Rescale pixel values to [0, 1]
)

def load_train_valid_data(datagen, data_dir, image_size, batch_size):
    # Load and preprocess training and validation data
    generator = datagen.flow_from_directory(
        data_dir,
        target_size=image_size,
        batch_size=batch_size,
        class_mode='categorical',  # For multi-class classification
    )
    
    return generator

def load_test_data(test_data_dir, image_size):   
    # Get a list of all image file paths in the "test" directory
    test_image_paths = [os.path.join(test_data_dir, fname) for fname in os.listdir(test_data_dir)]
    
    # Initialize an empty list to store test data and labels
    test_data, test_labels = [], []
    
    # Iterate through the image paths and load/preprocess the images
    for image_path in test_image_paths:
        if os.path.exists(image_path):            
            # Load the image
            img = load_img(image_path, target_size=image_size)
            
            # Convert the image to a numpy array and rescale pixel values
            img_array = img_to_array(img)
            img_array = img_array / 255.0  # Rescale pixel values to [0, 1]
            
            # Append the image data to the test_data list
            test_data.append(img_array)
            
            # Append a placeholder label (since class labels are not known for test images)
            test_labels.append(0)  # You can use any integer label, as actual labels are not known
    
    # Convert the test_data list to a numpy array
    test_data = np.array(test_data)
    
    # Convert the test_labels list to a numpy array
    test_labels = np.array(test_labels)
    
    return test_data, test_labels

train_generator = load_train_valid_data(datagen, train_data_dir, image_size, batch_size)
validation_generator = load_train_valid_data(datagen, validation_data_dir, image_size, batch_size)
test_data, test_labels = load_test_data(test_data_dir, image_size)

# Number of training samples
num_train_samples = train_generator.samples

# Number of validation samples
num_validation_samples = validation_generator.samples

# Number of testing samples
num_test_samples = len(test_data)

# The labels are typically encoded as integers, where each integer corresponds to a class.
# You can optionally get the class names associated with the labels like this:
class_names = list(train_generator.class_indices.keys())

# Number of classes
num_classes = train_generator.num_classes

#print('train_data dimensions: ', train_generator[0][0].shape)

# Now, you have loaded and preprocessed your training and validation data from separate directories
# You can use these generators for training and validation during model training.

############################## model #################################
# Load the pre-trained ResNet-50 model without the top classification layer
base_model = ResNet50(weights='imagenet', include_top=False, input_shape=(224, 224, 3))

# Add a new classification layer for your specific disease classes
x = GlobalAveragePooling2D()(base_model.output)
x = Dense(128, activation='relu')(x)
predictions = Dense(num_classes, activation='softmax')(x)

# Create a new model with the modified classification layer
model = Model(inputs=base_model.input, outputs=predictions)

# Compile the model
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Use model.fit_generator for training
model.fit(
    train_generator,
    steps_per_epoch=train_generator.samples // train_generator.batch_size,  # Number of steps per epoch
    validation_data=validation_generator,
    validation_steps=validation_generator.samples // validation_generator.batch_size,  # Number of validation steps
    epochs=num_epochs
)

# Evaluate the model on the test dataset
test_loss, test_accuracy = model.evaluate(test_data, test_labels)
print(f'Test accuracy: {test_accuracy}')

# Save the model to the specified path
model.save(model_save_path)
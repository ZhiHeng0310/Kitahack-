import tensorflow as tf
from tensorflow.keras.models import load_model
import numpy as np
from tensorflow.keras.preprocessing import image

# SAME NormalizeLayer used during training
class NormalizeLayer(tf.keras.layers.Layer):
    def call(self, inputs):
        return tf.cast(inputs, tf.float32) / 127.5 - 1.0

# Load model
model = load_model(
    "waste_classifier.h5",
    custom_objects={"NormalizeLayer": NormalizeLayer}
)

print("✅ Model loaded successfully")

IMG_SIZE = 224
img_path = "C:/Kitahack3/dataset/Styrofoam_Plastic_Clean/Image_1.png"

# Load image
img_obj = image.load_img(img_path, target_size=(IMG_SIZE, IMG_SIZE))
img_array = image.img_to_array(img_obj)

# DO NOT normalize here (model handles it)
img_array = np.expand_dims(img_array, axis=0)

# Predict
preds = model.predict(img_array)
pred_index = np.argmax(preds[0])
confidence = preds[0][pred_index]

# Load labels
with open("C:/Kitahack3/ecosnap_android/assets/models/labels.txt", "r") as f:
    labels = [line.strip() for line in f.readlines()]

pred_label = labels[pred_index]

print(f"Predicted: {pred_label}, Confidence: {confidence:.4f}")

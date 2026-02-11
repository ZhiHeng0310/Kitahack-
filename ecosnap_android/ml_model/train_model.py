"""
Simple TensorFlow Model Training Script for Waste Classification
This script creates a basic CNN model for waste classification.
For production, use a larger dataset and more sophisticated architecture.


import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import numpy as np

# Model configuration
IMG_SIZE = 224
NUM_CLASSES = 9  # Based on labels.txt
BATCH_SIZE = 32
EPOCHS = 15

def create_model():
    #Create a simple CNN model for waste classification
    
    model = keras.Sequential([
        # Input layer
        layers.InputLayer(input_shape=(IMG_SIZE, IMG_SIZE, 3)),
        
        # Data Augmentation (Helps with small datasets) FROM GEMINI
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(0.1),

        # Normalization
        layers.Rescaling(1./255),
        
        # Convolutional blocks
        layers.Conv2D(32, (3, 3), activation='relu', padding='same'),
        layers.MaxPooling2D((2, 2)),
        layers.Dropout(0.2),
        
        layers.Conv2D(64, (3, 3), activation='relu', padding='same'),
        layers.MaxPooling2D((2, 2)),
        layers.Dropout(0.2),
        
        layers.Conv2D(128, (3, 3), activation='relu', padding='same'),
        layers.MaxPooling2D((2, 2)),
        layers.Dropout(0.3),
        
        layers.Conv2D(256, (3, 3), activation='relu', padding='same'),
        layers.MaxPooling2D((2, 2)),
        layers.Dropout(0.3),
        
        # Flatten and dense layers
        # layers.Flatten(),
        layers.GlobalAveragePooling2D(),
        layers.Dense(256, activation='relu'),
        layers.Dropout(0.5),
        layers.Dense(NUM_CLASSES, activation='softmax')
    ])
    
    return model

def compile_model(model):
    # Compile the model with optimizer and loss function
    
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model

def convert_to_tflite(model, output_path='waste_classifier.tflite'):
    #Convert Keras model to TensorFlow Lite format
    
    # Convert the model
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Optimize for mobile
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Convert
    tflite_model = converter.convert()
    
    # Save the model
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"Model saved to {output_path}")
    print(f"Model size: {len(tflite_model) / 1024:.2f} KB")

def load_real_dataset():
    # Load images from the 'dataset/' folder and split into Train/Val
    train_ds = keras.preprocessing.image_dataset_from_directory(
        'dataset/',
        validation_split=0.2,
        subset='training',
        seed=123,
        image_size=(IMG_SIZE, IMG_SIZE),
        batch_size=BATCH_SIZE,
        label_mode='categorical'
    )
    
    val_ds = keras.preprocessing.image_dataset_from_directory(
        'dataset/',
        validation_split=0.2,
        subset='validation',
        seed=123,
        image_size=(IMG_SIZE, IMG_SIZE),
        batch_size=BATCH_SIZE,
        label_mode='categorical'
    )
    
    return train_ds, val_ds

def main():
    # Main training pipeline
    # STEP 1: Load Data
    print("Loading real dataset from 'dataset/' folder...")
    train_ds, val_ds = load_real_dataset()

    # Print the classes found to double check order
    print(f"Classes found: {train_ds.class_names}")

    # STEP 2: Create and Compile Model
    print("Creating model...")
    model = create_model()
    model = compile_model(model)
    
    # STEP 3: Train
    print(f"\nStarting training for {EPOCHS} epochs...")
    history = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=EPOCHS
    )
    
    print("\nTraining complete!")
    
    # Save Keras model
    model.save('waste_classifier_keras.h5')
    print("Keras model saved to waste_classifier_keras.h5")
    
    # Convert to TensorFlow Lite
    print("\nConverting to TensorFlow Lite...")
    convert_to_tflite(model, 'waste_classifier.tflite')
    
    print("\n✅ Done! Copy 'waste_classifier.tflite' to assets/models/ in your Flutter project")

if __name__ == '__main__':
    main()

"""

"""
TO USE WITH REAL DATA:

1. Organize your images like this:
   dataset/
   ├── glass_bottle/
   │   ├── img1.jpg
   │   ├── img2.jpg
   ├── plastic_container/
   │   ├── img1.jpg
   │   ├── img2.jpg
   └── ...

2. Replace create_dummy_dataset() with:

def load_real_dataset():
    train_ds = keras.preprocessing.image_dataset_from_directory(
        'dataset/',
        validation_split=0.2,
        subset='training',
        seed=123,
        image_size=(IMG_SIZE, IMG_SIZE),
        batch_size=BATCH_SIZE
    )
    
    val_ds = keras.preprocessing.image_dataset_from_directory(
        'dataset/',
        validation_split=0.2,
        subset='validation',
        seed=123,
        image_size=(IMG_SIZE, IMG_SIZE),
        batch_size=BATCH_SIZE
    )
    
    return train_ds, val_ds

3. Then in main():
   train_ds, val_ds = load_real_dataset()
   history = model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS)
"""


"""
Production-Level TensorFlow Model Training Script
Waste Classification using MobileNetV2 (Optimized for TFLite + Flutter)
"""

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import numpy as np

# ==========================
# CONFIGURATION
# ==========================
IMG_SIZE = 224
NUM_CLASSES = 9
BATCH_SIZE = 32
EPOCHS_INITIAL = 25
EPOCHS_FINE_TUNE = 15
DATASET_PATH = "dataset/"
MODEL_NAME = "waste_classifier"

# ==========================
# LOAD DATASET
# ==========================
def load_dataset():
    train_ds = keras.utils.image_dataset_from_directory(
        DATASET_PATH,
        validation_split=0.2,
        subset="training",
        seed=123,
        image_size=(IMG_SIZE, IMG_SIZE),
        batch_size=BATCH_SIZE,
        label_mode="categorical"
    )

    val_ds = keras.utils.image_dataset_from_directory(
        DATASET_PATH,
        validation_split=0.2,
        subset="validation",
        seed=123,
        image_size=(IMG_SIZE, IMG_SIZE),
        batch_size=BATCH_SIZE,
        label_mode="categorical"
    )

    class_names = train_ds.class_names

    # Performance optimization
    AUTOTUNE = tf.data.AUTOTUNE
    train_ds = train_ds.prefetch(AUTOTUNE)
    val_ds = val_ds.prefetch(AUTOTUNE)

    return train_ds, val_ds, class_names


# ==========================
# CREATE MODEL
# ==========================
def create_model():
    # Data augmentation
    data_augmentation = keras.Sequential([
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(0.1),
        layers.RandomZoom(0.1),
    ])

    # Pretrained MobileNetV2 base
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(IMG_SIZE, IMG_SIZE, 3),
        include_top=False,
        weights="imagenet"
    )

    base_model.trainable = False  # Freeze for transfer learning

    inputs = keras.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
    x = data_augmentation(inputs)
    x = tf.keras.applications.mobilenet_v2.preprocess_input(x)
    x = base_model(x, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(NUM_CLASSES, activation="softmax")(x)

    model = keras.Model(inputs, outputs)

    return model, base_model


# ==========================
# COMPILE MODEL
# ==========================
def compile_model(model, learning_rate=0.001):
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=learning_rate),
        loss="categorical_crossentropy",
        metrics=["accuracy"]
    )
    return model


# ==========================
# CONVERT TO TFLITE
# ==========================
def convert_to_tflite(model, output_path="waste_classifier.tflite"):
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]

    tflite_model = converter.convert()

    with open(output_path, "wb") as f:
        f.write(tflite_model)

    print(f"✅ TFLite model saved: {output_path}")
    print(f"Model size: {len(tflite_model) / 1024:.2f} KB")


# ==========================
# MAIN TRAINING PIPELINE
# ==========================
def main():
    print("📂 Loading dataset...")
    train_ds, val_ds, class_names = load_dataset()
    print("Classes:", class_names)

    print("\n🏗 Creating MobileNetV2 model...")
    model, base_model = create_model()
    model = compile_model(model)

    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor="val_loss",
            patience=3,
            restore_best_weights=True
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.3,
            patience=2
        )
    ]

    # ==========================
    # STAGE 1: Transfer Learning
    # ==========================
    print("\n🚀 Stage 1: Training top layers...")
    model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=EPOCHS_INITIAL,
        callbacks=callbacks
    )

    # ==========================
    # STAGE 2: Fine-Tuning
    # ==========================
    print("\n🔧 Stage 2: Fine-tuning base model...")

    base_model.trainable = True

    # Freeze earlier layers, fine-tune last 15 layers
    for layer in base_model.layers[:-15]:
        layer.trainable = False

    model = compile_model(model, learning_rate=1e-5)

    model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=EPOCHS_FINE_TUNE,
        callbacks=callbacks
    )

    # Save full Keras model
    model.save(f"{MODEL_NAME}.h5")
    print(f"\n💾 Keras model saved: {MODEL_NAME}.h5")

    # Convert to TFLite
    print("\n📦 Converting to TFLite...")
    convert_to_tflite(model, f"{MODEL_NAME}.tflite")

    print("\n🎉 Training complete! Copy the .tflite file into your Flutter assets/models/ folder.")


if __name__ == "__main__":
    main()

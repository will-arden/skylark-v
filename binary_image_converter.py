import os
import sys
import random
from PIL import Image

# ============== USER VARIABLES BEGIN ============== #
SIZE_X                          = 32
SIZE_Y                          = 32
BW_THRESHOLD                    = 128
TXT_TO_IMG_INPUT_FILENAME       = "convert_this_to_an_img.txt"
TXT_TO_IMG_OUTPUT_FILENAME      = "img_result.png"
IMG_TO_TEXT_INPUT_FILENAME      = "convert_this_to_binary.png"
IMG_TO_TEXT_OUTPUT_FILENAME     = "binary_result.txt"
# ============== USER VARIABLES END ============== #

# ============== CONVERSION FUNCTIONS BEGIN ============== #
def random_sequence_gen(x, y):
    sequence = []                                   # Empty array of binary digits
    for i in range(x*y):
        sequence.append(random.choice([0, 1]))      # Fill with random numbers
    print("Random sequence generated.")
    return sequence                                 # Return the entire sequence

def sequence_gen(filename):
    sequence = []                                   # Empty array of binary digits
    try:
        with open(filename, 'r') as file:           # Open input file
            file_contents = file.read()             # and read the contents
            for line in file_contents:              # Iterate through every line
                line = line.strip()                 # Cleanup line
                for c in line:                      # Iterate through every character
                    # Check for non-binary digits/characters
                    if(c != "0" and c != "1"):
                        print("Invalid character",c," found.")
                        print("Please fix this issue and retry.\n")
                        sys.exit(1)
                    else:
                        sequence.append(int(c))     # Append the valid digits to the sequence
            return sequence                         # Return the entire sequence
    except FileNotFoundError:                       # Safely handle exception, in case catching is ommitted in user code
        print("\nCouldn't find:",filename+".")
        print("Please ensure the file exists and re-run this script.\n")
        sys.exit(1)

def image_gen(sequence, x, y):
    image = Image.new('1', (x, y))                  # Create a new image with 1-bit colour depth
    image.putdata(sequence)                         # Place the pixel data onto the image
    return image

def save_text(text, filename):
    try:
        with open(filename, 'w') as file:
            for element in text:
                file.write(str(element))
    except FileNotFoundError:                       # Safely handle exception, in case catching is ommitted in user code
        print("\nCouldn't find:",filename+".")
        print("Please ensure the file exists and re-run this script.\n")
        sys.exit(1)

def img_to_bit_array(filename, x, y, thres):

    img = Image.open(filename)                    # Open the input PNG
    img = img.convert('L')                          # Ensure the image is greyscale
    img = img.resize((x, y))                        # Resize the image appropriately
    # Create the array of bits
    bit_array = []                                  # Empty bit array
    i = 0
    for pixel in img.getdata():                     # Iterate through every pixel in the image
        i += 1                                      # Count the pixels
        if((((i-1) % x)==0) and (i != 1)):
            bit_array.append(str('\n'))             # Insert new line characters where necessary
        if(pixel < thres):                           # Depending on the configured threshold,
            bit_array.append(0)                     # polarise the pixels to be either black
        else:                                       # or white
            bit_array.append(1)                     

    return bit_array                                # Return the entire bit array
# ============== CONVERSION FUNCTIONS END ============== #

# ============== USER CODE BEGIN ============== #
try:

    # Bit Array --> PNG
    sequence = sequence_gen(TXT_TO_IMG_INPUT_FILENAME)  # Read the input file to generate a flattened list of 1's and 0's
    image = image_gen(sequence, SIZE_X, SIZE_Y)         # Generate an image from that sequence
    image.save(TXT_TO_IMG_OUTPUT_FILENAME)              # Save the image as a .PNG file
    print("Binary Text --> PNG\tComplete")

    # PNG --> Bit Array
    bit_array = img_to_bit_array(IMG_TO_TEXT_INPUT_FILENAME, SIZE_X, SIZE_Y, BW_THRESHOLD)
    save_text(bit_array, IMG_TO_TEXT_OUTPUT_FILENAME)
    print("PNG --> Binary Text\tComplete")

    sys.exit(0)                                         # Exit the program normally

except Exception as e:
    print("\nFailed with exception:",e)
    sys.exit(1)
# ============== USER CODE END ============== #

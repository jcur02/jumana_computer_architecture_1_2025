import numpy as np
import matplotlib.pyplot as plt
from tkinter import filedialog, Tk
import os
import math

# Función para leer el archivo .img como lo haces normalmente
def read_file(filename):
    with open(filename, "r") as f:
        tmp = f.read()
        tmp = tmp[:-2].split('\n')  # Elimina los dos últimos caracteres y divide en líneas
        arr = []
        for n in tmp:
            arr += n.split(' ')  # Divide cada línea por los espacios
    return [int(i) for i in arr]  # Convierte cada valor a entero

def display_image(image):
    """Muestra la imagen en escala de grises usando matplotlib."""
    if image is not None:
        plt.imshow(image, cmap='gray')
        plt.axis('off')  # Ocultar los ejes
        plt.show()
    else:
        print("Error: La imagen no se pudo cargar correctamente.")

def main():
    # Crea la ventana principal de Tkinter para seleccionar el archivo
    Tk().withdraw()  # No necesitamos la ventana principal de Tkinter
    file_path = filedialog.askopenfilename(
        initialdir='./',  # Dirección inicial (puedes modificarla)
        title="Selecciona el archivo .img",
        filetypes=(("Archivos .img", "*.img"), ("Todos los archivos", "*.*"))
    )
    
    if file_path:
        # Leer la imagen usando la función read_file
        img_data = read_file(file_path)
        
        # Calcular el tamaño de la imagen (se asume que la imagen es cuadrada)
        total_pixels = len(img_data)
        img_size = int(math.sqrt(total_pixels))  # Calcular la raíz cuadrada del número total de píxeles
        
        if img_size * img_size != total_pixels:
            print(f"Advertencia: El archivo no tiene un tamaño cuadrado. Tiene {total_pixels} píxeles.")
            return
        
        # Convertir la lista de datos en una matriz numpy y redimensionarla
        img = np.array(img_data).reshape((img_size, img_size))
        
        # Mostrar la imagen en escala de grises
        display_image(img)

if __name__ == "__main__":
    main()

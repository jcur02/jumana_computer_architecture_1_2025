import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.widgets import Button as Button
import os
import cv2
import numpy as np
from tkinter import filedialog, Tk
# from bilinear_interpolation import *


class UI:

    divs = range(0, 390, 97)[1:-1]
    quadrants = []
    index = 0
    path = None
    img = None
    visible = True

    def __init__(self):
        self.create_figure()

    def show_grid(self):
        for y1 in range(0, 388, 97):
            for x1 in range(0, 388, 97):
                x2 = x1 + 97
                y2 = y1 + 97
                self.quadrants.append([x1, y1, x2, y2])

    def create_figure(self):
        # Create figure with adjusted size for buttons
        self.fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(15, 7))  # Increase figure width to add space for buttons
        self.fig.patch.set_facecolor('snow')
        self.fig.canvas.manager.set_window_title('Individual Project')
        self.fig.set_facecolor('black')
        self.fig.suptitle('Bilinear Interpolation', fontweight="bold", color='white')
        self.fig.canvas.mpl_connect('button_press_event', self.on_press)
        plt.subplots_adjust(top=0.85, bottom=0.2, left=0.05, right=0.95)  # Adjust the space between the plots
        self.ax1 = axs[0]
        self.ax3 = axs[1]

        # SUBPLOTS CONFIGUTATION
        # Original image, settings
        self.ax1.set_title("Base", color='white')
        self.ax1.patch.set_facecolor('black')
        self.ax1.set_xlim(left=0, right=388)
        self.ax1.set_ylim(bottom=388, top=0)
        self.ax1.axes.set_xticks(self.divs)
        self.ax1.axes.set_yticks(self.divs)
        self.ax1.grid(alpha=1, color='darkgrey')
        plt.setp(self.ax1.spines.values(), linewidth=2, color='darkgrey')

        # Interpolated image, settings
        self.ax3.set_title("Interpolated", color='white')
        self.ax3.patch.set_facecolor('black')
        self.ax3.set_axis_off()

        # Square (for interaction)
        x = y = 20
        self.square = patches.Rectangle(
            (x, y), 88, 88, linewidth=4, edgecolor='red', facecolor='none')
        self.ax1.add_patch(self.square)

        # Visibility toggle
        self.toggle_visibility()

        # BUTTONS
        # Upload Button (top)
        ax_button = plt.axes([0.5 - 0.045, 0.5, 0.09, 0.075])  # Centered horizontally
        bn_load = Button(ax_button, 'Upload Image', color='darkgrey', hovercolor='lightsteelblue')
        bn_load.on_clicked(self.load_image)

        # Apply Button (bottom)
        ax_apply = plt.axes([0.5 - 0.045, 0.35, 0.09, 0.075])  # Centered horizontally, below the first one
        bn_apply = Button(ax_apply, 'Interpolate', color='slategray', hovercolor='lightsteelblue')
        bn_apply.on_clicked(self.execute)

        plt.show()

    # Toggle visibility of subplot 1 stuff
    def toggle_visibility(self):
        self.ax1.get_xaxis().set_visible(not self.visible)
        self.ax1.get_yaxis().set_visible(not self.visible)
        self.ax1.spines["top"].set_visible(not self.visible)
        self.ax1.spines["bottom"].set_visible(not self.visible)
        self.ax1.spines["right"].set_visible(not self.visible)
        self.ax1.spines["left"].set_visible(not self.visible)
        self.square.set_visible(not self.visible)
        self.visible = not self.visible
        plt.draw()

    # Move Rectangle (for interaction)
    def on_press(self, event):
        if not self.visible:
            return
        if event.inaxes == self.ax1:
            # Ensure click is within image bounds
            if event.xdata is None or event.ydata is None:
                return

            x = int(event.xdata)
            y = int(event.ydata)

            # Find quadrant index based on click position
            col = x // 97
            row = y // 97
            quadrant_index = row * 4 + col  # 4 columns in total

            if quadrant_index < len(self.quadrants):
                self.index = quadrant_index
                quadrant = self.quadrants[self.index]
                self.square.set_xy((quadrant[0] + 5, quadrant[1] + 5))
                self.fig.canvas.draw_idle()

    # Load Image
    def load_image(self, event):
        Tk().withdraw()
        self.path = filedialog.askopenfilename(
            initialdir=os.path.join(os.getcwd(), 'Images'),
            title="Select image",
            filetypes=(("Image files", "*.jpg *.jpeg *.png"),
                        ("All files", "*.*")))

        if (self.path is None):
            return

        self.img = self.discolor(cv2.imread(self.path))
        self.show_grid()
        self.square.set_xy((5, 5))
        self.index = 0

        self.ax1.imshow(self.img, cmap=plt.get_cmap('gray'))
        self.fig.canvas.draw_idle()

        if (not self.visible):
            self.toggle_visibility()

    # Grayscale the image
    def discolor(self, rgb):
        return np.dot(rgb[..., : 3], [1, 0, 0])

    # Apply algorithm
    def execute(self, event):
        if (self.path == None):
            return

        box = self.quadrants[self.index]
        selected_quadrant = self.img[box[1]:box[3], box[0]:box[2]]

        if (selected_quadrant is None):
            return

        # Write to txt.
        InterpolatedImage = algorithm(selected_quadrant.tolist(), selected_quadrant.shape[0])

        self.ax3.imshow(InterpolatedImage, cmap=plt.get_cmap('gray'))

interface = UI()

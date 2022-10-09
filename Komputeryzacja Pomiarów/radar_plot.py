# %%
import arcade
import math
from dataclasses import dataclass

from arcade.color import UFO_GREEN
from collect_radar_data import DataCollector
import random
import time
from typing import List, Tuple
# %%
WIDTH = 800
HEIGHT = 600
TITLE = "Radar scanner"

CENTER_X = WIDTH / 2
CENTER_Y = 0.25*HEIGHT
CENTER = (CENTER_X, CENTER_Y)
RADIANS_PER_FRAME = 0.02
MAX_RADAR_RADIUS = 350
MAX_RADAR_RADIUS_CM = 40
ONE_DEGREE = math.pi / 180.
LIFETIME = 3
 
 
@dataclass
class Color:
    R: int
    G: int
    B: int
    alpha: int

    @staticmethod
    def ufo_green():
        return Color(*arcade.color.UFO_GREEN, 255)

    @staticmethod
    def red():
        return Color(*arcade.color.RED, 255)

    def astuple(self):
        return (self.R, self.G, self.B, self.alpha)

# %%
class Line:

    def __init__(
        self,
        angle: float,
        length: int,
        creation_time: float,
        color: Color,
        start_cordinates: Tuple[float,float],
        line_width: float = 3,
    ):
        super().__init__()
        self.angle = angle
        self.length = length
        self.creation_time = creation_time
        self.color = color
        self.start_cordinates = start_cordinates
        self.line_width = line_width

    def __dict__(self):
        return {
            "angle": self.angle,
            "length": self.length,
            "creation_time": self.creation_time,
            "color": self.color,
            "start_coordinates": self.start_cordinates,
            "line_width": self.line_width
        }

    @property
    def end_coordinates(self) -> Tuple[float,float]:
        x = self.length * math.sin(self.angle)
        y = self.length * math.cos(self.angle)
        x_start, y_start = self.start_cordinates
        return (x_start + x, y_start + y)

    def draw(self):
        arcade.draw_line(
            *self.start_cordinates,
            *self.end_coordinates,
            self.color.astuple(),
            self.line_width
        )

class Point:

    def __init__(
        self,
        creation_time: float,
        color: Color,
        cordinates: Tuple[float,float],
    ):
        super().__init__()
        self.creation_time = creation_time
        self.color = color
        self.cordinates = cordinates

    def __dict__(self):
        return {
            "creation_time": self.creation_time,
            "color": self.color,
            "coordinates": self.cordinates,
        }


    def draw(self):
        arcade.draw_point(
            *self.cordinates,
            self.color.astuple(),
            10
        )


# %%
class LineBuffer:

    def __init__(self, line_lifetime: int) -> None:
        """
        :param line_lifetime: in seconds
        """
        self.lines: List[Line] = []
        self.line_lifetime = line_lifetime

    def add(self, line):
        self.lines.append(line)

    def __clean_and_update_lines(self):
        for index, line in enumerate(self.lines):
            delta_time = time.time() - line.creation_time
            if delta_time > self.line_lifetime:
                self.lines.pop(index)
                continue
            new_transparency = int((1 - delta_time/float(self.line_lifetime)) * 255)
            self.lines[index].color.alpha = new_transparency

    def draw_lines(self):
        self.__clean_and_update_lines()
        for line in self.lines:
            line.draw()

class PointBuffer:

    def __init__(self, point_lifetime: int) -> None:
        """
        :param point_lifetime: in seconds
        """
        self.points: List[Point] = []
        self.point_lifetime = point_lifetime

    def add(self, point):
        self.points.append(point)

    def __clean_and_update_points(self):
        for index, point in enumerate(self.points):
            delta_time = time.time() - point.creation_time
            if delta_time > self.point_lifetime:
                self.points.pop(index)
                continue
            new_transparency = int((1 - delta_time/float(self.point_lifetime)) * 255)
            self.points[index] = Point(point.creation_time, Color(point.color.R, point.color.G, point.color.B, new_transparency), point.cordinates)

    def draw_points(self):
        self.__clean_and_update_points()
        for point in self.points:
            point.draw()

def draw_semicircle(radius: float):
    arcade.draw_arc_outline(
        *CENTER,
        start_angle=0,
        end_angle=180,
        width=radius*2,
        height=radius*2,
        color=arcade.color.UFO_GREEN
    )

def coordinates_to_absoulute(x, y) -> Tuple[float, float]:
    return (x + CENTER_X, y + CENTER_Y)

def draw_line(
    angle,
    length=MAX_RADAR_RADIUS,
    color=arcade.color.UFO_GREEN,
    line_width=1,
):
    x = length * math.sin(angle)
    y = length * math.cos(angle)

    arcade.draw_line(*CENTER, *coordinates_to_absoulute(x,y), color, line_width)

def draw_detected_object_as_line(
    angle,
    length,
    color=arcade.color.RED,
    line_width=1,
):
    x_start = length * math.sin(angle)
    y_start = length * math.cos(angle)
    x_end = MAX_RADAR_RADIUS * math.sin(angle)
    y_end = MAX_RADAR_RADIUS * math.cos(angle)

    arcade.draw_line(
        *coordinates_to_absoulute(x_start, y_start),
        *coordinates_to_absoulute(x_end, y_end),
        color, line_width
    )
    pass

def write_angles(angle, dr=1.02):
    x = -(MAX_RADAR_RADIUS)*math.sin(angle)*dr
    y = (MAX_RADAR_RADIUS)*math.cos(angle)*dr

    if x < 0:
        x = x-25
    arcade.draw_text(
        "%.2f" % (angle+math.pi/2),
        *coordinates_to_absoulute(x, y),
    )

def draw_background_lines(n):
    line_angle = 0
    delta_radians = math.pi/(n)
    for i in range(n+1):
        line_angle = -math.pi/2 + i*delta_radians
        draw_line(line_angle)
        write_angles(line_angle)

def draw_background_arcs(n, radius_in_cm=MAX_RADAR_RADIUS_CM):
    arc_radius = 0
    delta_radius = MAX_RADAR_RADIUS/n
    d_rad_cm = radius_in_cm/n
    rad_cm = 0
    for i in range(n+1):
        arc_radius = i*delta_radius
        draw_semicircle(arc_radius)
        arcade.draw_text(
            f"{i*d_rad_cm} cm",
            *coordinates_to_absoulute(arc_radius-10, -20),
        )

def draw_background(radius_in_cm):
    draw_background_arcs(4, radius_in_cm=radius_in_cm)
    draw_background_lines(6)

def convert_cm_to_px(distance_cm):
    return int(distance_cm/float(MAX_RADAR_RADIUS_CM) * MAX_RADAR_RADIUS)

def on_draw(file):
    angle = on_draw.angle
    if on_draw.backwards:
        on_draw.angle += RADIANS_PER_FRAME
    else:
        on_draw.angle -= RADIANS_PER_FRAME

    if on_draw.angle > math.pi:
        on_draw.backwards = True

    arcade.start_render()
    draw_background(radius_in_cm=MAX_RADAR_RADIUS_CM)
    angle, distance_cm = next(on_draw.data_collector.radar_data())
    distance_cm = distance_cm if distance_cm <= MAX_RADAR_RADIUS_CM else MAX_RADAR_RADIUS_CM
    distance_px = convert_cm_to_px(distance_cm)
    new_angle = -1*angle*ONE_DEGREE

    file.write(f"{float(angle)}, {float(distance_cm)}\n")
    file.flush()

    current_time = time.time()

    green_line = Line(new_angle, distance_px, current_time, Color.ufo_green(), CENTER)
    if distance_cm < MAX_RADAR_RADIUS_CM:
        red_point = Point(current_time, Color.red(), green_line.end_coordinates)
        on_draw.point_buffer.add(red_point)

    on_draw.line_buffer.add(green_line)
    on_draw.line_buffer.draw_lines()
    on_draw.point_buffer.draw_points()
    arcade.finish_render()

on_draw.angle = 0
on_draw.backwards = False
on_draw.data_collector = DataCollector()
on_draw.line_buffer = LineBuffer(LIFETIME)
on_draw.point_buffer = PointBuffer(LIFETIME)
# %%

def get_data_filename():
    print("Podaj ścieżkę, do której chcesz zapisać dane.")
    filename = input()
    if not isinstance(filename, str) or filename == "":
        return "data.csv"
    return filename

def main():
    arcade.open_window(WIDTH, HEIGHT, TITLE)
    arcade.set_background_color(arcade.color.BLACK)
    with open(get_data_filename(), 'w') as file:
        file.write(f"angle_deg, distance_cm\n")
        while 1:
            on_draw(file)

    arcade.run()
    arcade.close_window()

# %%
if __name__ == "__main__":
    main()

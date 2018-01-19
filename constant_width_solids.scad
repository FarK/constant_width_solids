$fs=0.01;
$fa=1;

function radius_from_width(width, vertices) = width*sin(90/vertices) / sin(180/vertices);

module external_triangles(vertices, size) {
	n = len(vertices);
	angle = 180/n;

	triangle_points= [[0, 0], size*[cos(angle), sin(angle)], size*[1, 0]];

	for (i = [0:1:n-1]) {
		translate(vertices[i])
			rotate(-i*(360/n))
				rotate(-angle/2+90)polygon(triangle_points);
	}
}

module constant_width_curve(vertices, width, round_out)
{
	fixed_width = width - round_out;
	odd_vertices = (vertices % 2)? vertices : vertices + 1;
	radius = radius_from_width(fixed_width, odd_vertices);
	sep_angle = 360/odd_vertices;

	points = [for (i = [0:1:odd_vertices-1])
		radius*[sin(i*sep_angle), cos(i*sep_angle)]
	];

	union() {
		intersection() {
			for (i = [0:1:odd_vertices-1]) {
				translate(points[i]) circle(round_out/2);
			}
			external_triangles(points, round_out);
		}

		difference() {
			intersection_for (p = points) {
				translate(p) circle(fixed_width + round_out/2);
			}
			external_triangles(points, round_out);
		}
	}

	//#polygon(points);
}

module constant_width_solid(vertices, width, round_out=0, center=false)
{
	radius = radius_from_width(width, vertices);
	center_vector = center? [0, 0, 0] : [width/2, width/2, width-radius];

	translate(center_vector) {
		rotate_extrude() {
			difference() {
				constant_width_curve(vertices, width, round_out);
				translate([-width, -width, 0])
					square([width, 2*width]);
			}
		}
	}
}

for (i = [3:2:11]) {
	translate([(i-3)*60, 0, 0]) constant_width_solid(i, 50);
	translate([(i-3)*60, 60, 0]) constant_width_solid(i, 50, 25);
}
//constant_width_solid(3, 51.9615, 25);

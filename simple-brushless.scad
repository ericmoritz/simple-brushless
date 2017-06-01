part = "all"; // ["all", "frame", "aio"]

MOTOR_SIZE = 11; // [11:11xx, 18:18xx, 22:22xx, 23:23xx]

// Stack Hole Spacing
STACK_HOLE_SPACING = 20; // [30.5:30.5x30.5, 20:20x20, 16:16x16] 

// Prop clearance from the stack
PROP_CLEARANCE = 1;

// What is the prop size in inches?
PROP_SIZE_INCHES=2;

// How thick do you want the frame to be?
FRAME_THICKNESS=3;

// How thick do you need the prop guard rails to be
GUARD_WIDTH=2;

/* [Camera Options] */
aio_camera_height = 3;
aio_lens_diameter = 8.2;
aio_lens_margin = 3;
aio_lens_gap = 4;
aio_angle = 20;
aio_to_lens = 10;
aio_bottom = -2;
aio_board_depth = 10;

/* [Advanced Options] */

// Distance from the edge of the arm and the motor holes
MOTOR_MOUNT_MARGIN=2;

// Diameter of the center hole in the frame
MOTOR_MOUNT_CENTER_DIAMETER=5;


/* [Hidden] */
M3 = 3.4; 
M2 = 2.4;

// Margin for the outside standoffs
STANDOFF_MARGIN=3;
STANDOFF_HOLE_RADIUS=M3/2;

prop_size = PROP_SIZE_INCHES * 25.4; 

// Size of the board (calculated from the hole spacing)
stack_board_size = (
  STACK_HOLE_SPACING == 16 ? 20 :
  STACK_HOLE_SPACING == 20 ? 25 :
  STACK_HOLE_SPACING == 30.5 ? 36 : 
  0
);

stack_hole_spacing = (
  STACK_HOLE_SPACING != 0 ? STACK_HOLE_SPACING :
  0
);

stack_hole_diameter=(
  STACK_HOLE_SPACING >= 20 ? M3 :
  STACK_HOLE_SPACING >= 16 ? M2 :
  0
);


// The diagonal distance between motor holes
motor_mount_diaganal=(
   MOTOR_SIZE == 11 ? 9 :
   MOTOR_SIZE == 18 ? 12 :
   MOTOR_SIZE == 22 ? 16 : 
   MOTOR_SIZE == 23 ? 16 : 
   0
 );

// The diameter of the moter holes
motor_mount_hole_size=(
  MOTOR_SIZE >= 22 ? M3 :
  MOTOR_SIZE >= 11 ? M2 :
  0
);

wheelbase = (
  stack_board_size / sin(45) + 
  PROP_CLEARANCE * 2 + 
  prop_size
);

motorHoleDistance = sin(45) * motor_mount_diaganal;

guard_ir = prop_size / 2 + PROP_CLEARANCE;
guard_or = guard_ir + GUARD_WIDTH;

arm_length = (
  wheelbase / 2 +
  guard_ir
);


standoff_offset = (
    arm_length + 
    STANDOFF_MARGIN 
);

echo("Wheelbase: ");
echo(wheelbase);


// modules
module motorHoles() {
  offset = motorHoleDistance / 2;
  translate([-offset+wheelbase/2, -offset,FRAME_THICKNESS*-1 / 2 ]) {
    rotate([0,0,0]) {
      union() {
        translate([motorHoleDistance/2,motorHoleDistance/2,-FRAME_THICKNESS/2]) {
          cylinder(r=MOTOR_MOUNT_CENTER_DIAMETER/2, h=FRAME_THICKNESS*2);
        }
        translate([0,0,-FRAME_THICKNESS/2]) {
          cylinder(r=motor_mount_hole_size/2, h=FRAME_THICKNESS*2);
        }
        translate([0,motorHoleDistance,-FRAME_THICKNESS/2]) {
          cylinder(r=motor_mount_hole_size/2, h=FRAME_THICKNESS*2);
        }
        translate([motorHoleDistance,0,-FRAME_THICKNESS/2]) {
          cylinder(r=motor_mount_hole_size/2, h=FRAME_THICKNESS*2);
        }
        translate([motorHoleDistance,motorHoleDistance,-FRAME_THICKNESS/2]) {
          cylinder(r=motor_mount_hole_size/2, h=FRAME_THICKNESS*2);
        }
      }
    }
  }
}

module base() {
  width = motorHoleDistance + MOTOR_MOUNT_MARGIN*2;
  length = arm_length + 1; // the + 1 seals the manifold
  translate([length/2,0,0]) {
    cube([length, width, FRAME_THICKNESS], center=true);
  }
}

module guard() {
  translate([wheelbase/2,,0,-FRAME_THICKNESS/2]) {
  difference() {
      cylinder(r=guard_or, h=FRAME_THICKNESS);
      cylinder(r=guard_ir, h=FRAME_THICKNESS*2);
    }
  }
}

module stackHoles() {
  offset = stack_hole_spacing / sin(45) / 2;
  translate([offset,0,-FRAME_THICKNESS]) {
    cylinder(r=stack_hole_diameter/2, h=FRAME_THICKNESS*2);
  }
}

module standoffHole() {
  translate([standoff_offset, 0, -FRAME_THICKNESS]) {
    cylinder(r=STANDOFF_HOLE_RADIUS, h=FRAME_THICKNESS*2);
  }
}
module standoffTab() {
  translate([0,0,0]) {
    translate([standoff_offset, 0, -FRAME_THICKNESS/2]) {
      cylinder(r=STANDOFF_MARGIN, h=FRAME_THICKNESS);
    }
  }
}
module arm() {
  difference() {
    union() {
      base();
      guard();
      standoffTab();
    }
    motorHoles();
    stackHoles();
    standoffHole();
  } 
}
module frame() {
  arm();
  rotate([0,0,90]) {
    arm();
  }
  rotate([0,0,180]) {
    arm();
  }
  rotate([0,0,-180]) {
    arm();
  }

  rotate([0,0,-90]) {
    arm();
  }
}
module aio_camera() {
  thickness = FRAME_THICKNESS;
  
  plate_size = [
    stack_board_size,stack_board_size, thickness
  ];
  
  holder_z = aio_to_lens + aio_lens_diameter/2 + aio_bottom;
  holder_offset = tan(aio_angle) * (holder_z / 2);
  holder_size = [
        aio_lens_diameter+aio_lens_margin*2, 
        thickness,
        holder_z
  ];
  brace_size = [
    (arm_length+STANDOFF_MARGIN) / sin(45),
    FRAME_THICKNESS,
    FRAME_THICKNESS
  ];
  brace_translation = [0,0,holder_size[2]/2-0.5];
  rotation = [0,0,45];
  translation = [
    brace_size[0]/2 * sin(45),
    brace_size[0]/2 * sin(45) * -1,
    holder_size[2]/2
  ];
  tab_reset = [
    -arm_length-STANDOFF_MARGIN,
    0,
    brace_translation[2]
  ];
  tab_offset = brace_size[0]/2;
  // standoff mount 

  translate(translation)
  rotate(rotation) {
    
    // brace
    difference() {
      hull() {
        translate(tab_reset  + [tab_offset,0,0])
          standoffTab();
        translate(tab_reset  - [tab_offset,0,0])
          standoffTab();
        translate(brace_translation) // TODO calculator the 0.5
          cube(brace_size, center=true);
      }
      translate(tab_reset  + [tab_offset,0,0])
        standoffHole();
      translate(tab_reset  - [tab_offset,0,0])
        standoffHole();    
    }
    // holder
    translate([0,-holder_offset,0]) {
      rotate([-aio_angle,0,0]) {
        difference() {
          cube(holder_size, center=true);
          translate([0,thickness*2,holder_size[2]/2-aio_to_lens]) {
            rotate([90,0,0])
              cylinder(r=aio_lens_diameter/2, h=thickness*4);
          }
          translate([0,0,-aio_to_lens]) {
            cube([aio_lens_gap,thickness*4,holder_size[2]], center=true);
          }
        }
      }
    } 


  }
}

if (part == "frame" || part == "all") {
 frame();
}
if (part == "aio" || part == "all") {
  aio_camera();
}
$fn=64;
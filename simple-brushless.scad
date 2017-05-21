M3 = 3.2; 
M2 = 2.2;

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

/* [Advanced Options] */

// Distance from the edge of the arm and the motor holes
MOTOR_MOUNT_MARGIN=2;

// Diameter of the center hole in the frame
MOTOR_MOUNT_CENTER_DIAMETER=5;

// Margin for the outside standoffs
STANDOFF_MARGIN=3;

/* [Hidden] */
//$fn=64;

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

guard_ir = prop_size / 2;
guard_or = guard_ir + GUARD_WIDTH;

arm_length = (
  wheelbase / 2 +
  guard_ir
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
  translate([stack_hole_spacing/2,0,-FRAME_THICKNESS]) {
    cylinder(r=stack_hole_diameter/2, h=FRAME_THICKNESS*2);
  }
}

module standoffHole() {
  offset = (
    arm_length + 
    STANDOFF_MARGIN 
  );
  translate([offset, 0, -FRAME_THICKNESS]) {
    cylinder(r=1.5, h=FRAME_THICKNESS*2);
  }
}
module standoffTab() {
  offset = (
    arm_length +
    STANDOFF_MARGIN
  );
  translate([0,0,]) {
    translate([offset, 0, -FRAME_THICKNESS/2]) {
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
$fn=64;
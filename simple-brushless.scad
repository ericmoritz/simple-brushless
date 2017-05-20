$fn=64;

/* [Basic Config] */

// Motor size
MOTOR_SIZE = 11; // [11]

// Stack Hole Spacing
STACK_HOLE_SPACING = 20; // [16, 20, 30.5]

// Prop clearance from the stack
STACK_CLEARANCE = 1;

/* [Frame] */

// How thick do you want the frame to be?
FRAME_THICKNESS=3;

// How thick do you need the prop guard rails to be
GUARD_WIDTH=2;

/* Props */

// What is the prop size in inches?
PROP_SIZE_INCHES=2;

/* [Advanced Options] */

 // Size of the board (calculated from the hole spacing)
STACK_BOARDSIZE = (
  STACK_HOLE_SPACING == 16 ? 20 :
  STACK_HOLE_SPACING == 20 ? 25 :
  36
);

// The diagonal distance between motor holes
MOTOR_MOUNT_DIAMETER=(
   MOTOR_SIZE == 11 ? 9 :
   MOTOR_SIZE == 18 ? 12 :
   MOTOR_SIZE == 22 ? 16 : 
   MOTOR_SIZE == 23 ? 16 : 0
 );

// The diameter of the moter holes (m2 by default)
MOTOR_MOUNT_HOLESIZE=(
  MOTOR_SIZE <= 18 ? 2 : 3
);

// Distance from the edge of the arm and the motor holes
MOTOR_MOUNT_MARGIN=5;

// Diameter of the center hole in the frame
MOTOR_MOUNT_CENTER_DIAMETER=5;

// Hole diameter
STACK_HOLE_DIAMETER=(
  STACK_HOLE_SPACING < 20 ? 2 : 3
);

// Margin for the outside standoffs
STANDOFF_MARGIN=5;

/* [Hidden] */
PROP_SIZE = PROP_SIZE_INCHES * 25.4; 

wheelbase = (
  STACK_BOARDSIZE + STACK_CLEARANCE + PROP_SIZE
);
side = (
  (sin(45) * wheelbase) // distance between motors horizontally
  + PROP_SIZE // clearance for props (both motors horizontally)
  + GUARD_WIDTH * 2 // size of both sides of the guard
);
motorHoleDistance = sin(45) * MOTOR_MOUNT_DIAMETER;

// modules
module motorHoles() {
  center_offset = MOTOR_MOUNT_HOLESIZE - motorHoleDistance;
  // center the module
  translate([0,center_offset,FRAME_THICKNESS*-1 / 2 ]) {
    rotate([0,0,45]) {
      union() {
        translate([motorHoleDistance/2,motorHoleDistance/2,0]) {
          cylinder(r=MOTOR_MOUNT_CENTER_DIAMETER/2, h=FRAME_THICKNESS*2);
        }
        translate([0,0,-FRAME_THICKNESS/2]) {
          cylinder(r=MOTOR_MOUNT_HOLESIZE/2, h=FRAME_THICKNESS*2);
        }
        translate([0,motorHoleDistance,-FRAME_THICKNESS/2]) {
          cylinder(r=MOTOR_MOUNT_HOLESIZE/2, h=FRAME_THICKNESS*2);
        }
        translate([motorHoleDistance,0,-FRAME_THICKNESS/2]) {
          cylinder(r=MOTOR_MOUNT_HOLESIZE/2, h=FRAME_THICKNESS*2);
        }
        translate([motorHoleDistance,motorHoleDistance,-FRAME_THICKNESS/2]) {
          cylinder(r=MOTOR_MOUNT_HOLESIZE/2, h=FRAME_THICKNESS*2);
        }
      }
    }
  }
}

module base() {
  width = motorHoleDistance + MOTOR_MOUNT_MARGIN;
  length = side / sin(45);
  rotate([0,0,45]) {
    cube([width, length, FRAME_THICKNESS], center=true);
  }
    rotate([0,0,-45]) {
    cube([width, length, FRAME_THICKNESS], center=true);
  }
  translate([0,side/2,0]) {
    cube([side, GUARD_WIDTH, FRAME_THICKNESS], center=true);
  }
  translate([0,-side/2,0]) {
    cube([side, GUARD_WIDTH, FRAME_THICKNESS], center=true);
  }  
  translate([side/2, 0,0]) {
    cube([GUARD_WIDTH, side, FRAME_THICKNESS], center=true);
  }
  translate([-side/2, 0 ,0]) {
    cube([GUARD_WIDTH, side, FRAME_THICKNESS], center=true);
  }
  //cube([side, side, FRAME_THICKNESS], center=true);
}

module allMotorHoles() {
  distance = sin(45) * wheelbase;
  center = distance / 2;
  translate([-center, -center, 0]) {
  translate([0, 0,0]) {
    motorHoles();
  }
  translate([distance, 0,0]) {
    motorHoles();
  }
  translate([0, distance,0]) {
    motorHoles();
  }
  translate([distance, distance,0]) {
    motorHoles();
  }
}
}
module stackHoles() {
  translate([-STACK_HOLE_SPACING/2,-STACK_HOLE_SPACING/2,-FRAME_THICKNESS/2]) {
    translate([0,0,0]) {
      cylinder(r=STACK_HOLE_DIAMETER/2, h=FRAME_THICKNESS*2);
    }
    translate([0,STACK_HOLE_SPACING,0]) {
      cylinder(r=STACK_HOLE_DIAMETER/2, h=FRAME_THICKNESS*2);
    }
    translate([STACK_HOLE_SPACING,0,0]) {
      cylinder(r=STACK_HOLE_DIAMETER/2, h=FRAME_THICKNESS*2);
    }
    translate([STACK_HOLE_SPACING,STACK_HOLE_SPACING,0]) {
      cylinder(r=STACK_HOLE_DIAMETER/2, h=FRAME_THICKNESS*2);
    }
  }
}

module standoffHoles() {
  offset = side/2 - STANDOFF_MARGIN;
  translate([0,0,-FRAME_THICKNESS]) {
    translate([-offset, -offset,0]) {
      cylinder(r=1.5, h=FRAME_THICKNESS*2);
    }
    translate([offset, offset,0]) {
      cylinder(r=1.5, h=FRAME_THICKNESS*2);
    }
    translate([-offset, offset,0]) {
      cylinder(r=1.5, h=FRAME_THICKNESS*2);
    }
    translate([offset, -offset,0]) {
      cylinder(r=1.5, h=FRAME_THICKNESS*2);
    }
  }
}
difference() {
  base();
  allMotorHoles();
  stackHoles();
  standoffHoles();
}

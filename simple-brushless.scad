
// CFG values
FRAME_THICKNESS=2;
GUARD_WIDTH=2;
WHEELBASE=80;
PROPSIZE=56;
MOTOR_MOUNT_DIAMETER=9;
MOTOR_MOUNT_HOLESIZE=2; // m2 for 11xx class
MOTOR_MOUNT_MARGIN=5;

STACK_HOLE_SPACING=16;
STACK_HOLE_DIAMETER=3;

STANDOFF_MARGIN=5;

// Internal values
side = (
  (sin(45) * WHEELBASE) // distance between motors horizontally
  + PROPSIZE // clearance for props (both motors horizontally)
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
  distance = sin(45) * WHEELBASE;
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
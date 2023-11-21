void init_gpio() {
  DDRB = 0b00011001;
  PORTB = 0b00000110;
  DDRD |= (1 << 7) | (1 << 6);
  PORTD &= ~(1 << 7);
}

void setup() {
  init_gpio();
  Serial.begin(1000000);
  Serial.setTimeout(10000);
}

void loop() {
  run_command();
}

// =================================================================              MOTORS    /    REAL TIME STUFF          ==================================================================================

#define SELECT_X DDRB |= (1); DDRD &= ~(1 << 7)
#define SELECT_Z DDRB &= ~(1); DDRD |= (1 << 7)
#define STEP_POS PORTB &= ~(1 << 3)
#define STEP_NEG PORTB |= (1 << 3)

#define SELECT_X_POS SELECT_X; STEP_POS
#define SELECT_X_NEG SELECT_X; STEP_NEG
#define SELECT_Z_POS SELECT_Z; STEP_POS
#define SELECT_Z_NEG SELECT_Z; STEP_NEG

typedef struct {
  uint16_t trip;
  uint16_t remain;
} axis_state;

#define ACCEL_ARRAY_LEN 256
const uint8_t accel_array[ACCEL_ARRAY_LEN] = {164, 126, 106, 94, 85, 78, 73, 68, 65, 62, 59, 56, 54, 52, 51, 49, 48, 46, 45, 44, 43, 42, 41, 40, 40, 39, 38, 38, 37, 36, 36, 35, 35, 34, 34, 33, 33, 32, 32, 32, 31, 31, 30, 30, 30, 29, 29, 29, 29, 28, 28, 28, 28, 27, 27, 27, 27, 26, 26, 26, 26, 26, 25, 25, 25, 25, 25, 24, 24, 24, 24, 24, 24, 23, 23, 23, 23, 23, 23, 23, 22, 22, 22, 22, 22, 22, 22, 22, 21, 21, 21, 21, 21, 21, 21, 21, 21, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,};
uint16_t x_pos = 0;
uint16_t z_pos = 0;
uint8_t gear = 5;
uint16_t accel_cap = ACCEL_ARRAY_LEN;
axis_state m_state;

ISR(TIMER1_COMPA_vect) {
  PORTB |= (1 << 4);
}

ISR(TIMER1_COMPB_vect) {
  TCNT1 -= OCR1B;
  uint16_t accel_array_idx = m_state.trip;
  if (accel_array_idx > m_state.remain) {
    accel_array_idx = m_state.remain;
  }
  accel_array_idx /= 4;
  if (accel_array_idx >= accel_cap) {
    accel_array_idx = accel_cap - 1;
  } else {
    PORTD &= ~(1 << 6);
  }
  OCR1A = (OCR1B = ((uint16_t) accel_array[accel_array_idx]) << (8 - gear)) - 5;
  laser_check();

  PORTB &= ~(1 << 4);

  
  m_state.trip++;
  m_state.remain--;
  if (m_state.remain == 0) {
    TIMSK1 = 0;
  }
}

void accelM(uint16_t dist) {
  if (dist == 0) {
    return;
  }

  m_state.trip = 0;
  m_state.remain = dist;

  OCR1A = (((uint16_t) accel_array[0]) << (8 - gear));
  TCCR1A = 0;
  TCCR1B = 2;
  TCCR1C = 0;
  TCNT1 = 0;
  TIMSK1 = 6;
}

void waitForM() {
  while (TIMSK1) {
  }
}

void accelToAndWait(uint16_t x, uint16_t z) {
  // select x
  uint16_t dist = x - x_pos;
  if (x >= x_pos) {
    SELECT_X_POS;
  } else {
    dist = -dist;
    SELECT_X_NEG;
  }

  accel_cap = ACCEL_ARRAY_LEN;
  accelM(dist);
  waitForM();
  x_pos = x;

  // select z
  dist = z - z_pos;
  if (z >= z_pos) {
    SELECT_Z_POS;
  } else {
    dist = -dist;
    SELECT_Z_NEG;
  }

  accel_cap = ACCEL_ARRAY_LEN / 16;
  accelM(dist);
  waitForM();
  z_pos = z;
}

void findHome() {
  uint8_t old_gear = gear;

  // Move towards 0 quickly
  accel_cap = ACCEL_ARRAY_LEN;
  gear = 3;
  SELECT_X_NEG;
  accelM(65535);
  while (PINB & (1 << 2)) {
    m_state.remain = 65535;
  }
  TIMSK1 = 0;

  // Back off the limit switch
  SELECT_X_POS;
  accelM(500);
  waitForM();

  // Move towards 0 slowly
  gear = 1;
  SELECT_X_NEG;
  accelM(65535);
  while (PINB & (1 << 2)) {
    m_state.remain = 65535;
  }
  TIMSK1 = 0;

  // Now do the same thing with z
  // Move towards 0 quickly
  gear = 3;
  accel_cap = ACCEL_ARRAY_LEN / 16;
  SELECT_Z_NEG;
  accelM(65535);
  while (PINB & (1 << 1)) {
    m_state.remain = 65535;
  }
  TIMSK1 = 0;

  // Back off the limit switch
  SELECT_Z_POS;
  accelM(500);
  waitForM();

  // Move towards 0 slowly
  gear = 1;
  SELECT_Z_NEG;
  accelM(65535);
  while (PINB & (1 << 1)) {
    m_state.remain = 65535;
  }
  TIMSK1 = 0;

  x_pos = 0;
  z_pos = 0;

  gear = old_gear;
}


// =================================================================              DRAWING PARAMETERS            ==================================================================================

uint8_t pixel_array[1024];
uint8_t steps_per_pixel = 1;
uint16_t bitmap_width = 8192;
uint8_t backlash = 45;
uint8_t laser_enabled = 0;

inline void laser_check() {
  if (!laser_enabled) {
    return;
  }
  if (m_state.trip <= 4 * ACCEL_ARRAY_LEN + backlash) {
    return;
  }
  if (m_state.remain < 4 * ACCEL_ARRAY_LEN) {
    return;
  }
  
  // this is where we decide whether or not to turn on the laser.
  // After 1024 steps the head is done accelerating, then we subtract the backlash and then go
  uint16_t pixel_index = 0;
  if (PORTB & (1 << 3)) {
    pixel_index = m_state.remain - 4 * ACCEL_ARRAY_LEN;
  } else {
    pixel_index = m_state.trip - 4 * ACCEL_ARRAY_LEN - backlash;
  }
  pixel_index /= steps_per_pixel;

  uint8_t bit_index = pixel_index % 8;
  pixel_index /= 8;

  if (pixel_array[pixel_index] & (1 << (8 - pixel_index))) {
    PORTD |= (1 << 6);
  } else {
    PORTD &= ~(1 << 6);
  }
}

void draw_line(uint8_t is_x_pos) {
  if (is_x_pos) {
    SELECT_X_POS;
  } else {
    SELECT_X_NEG;
  }

  uint16_t dist = (bitmap_width * steps_per_pixel) + 8 * ACCEL_ARRAY_LEN + backlash;
  accel_cap = ACCEL_ARRAY_LEN;
  laser_enabled = 1;
  accelM(dist);
  waitForM();
  laser_enabled = 0;
  if (is_x_pos) {
    x_pos += dist;
  } else {
    x_pos -= dist;
  }
}


// =================================================================              FRONTEND FUNCTIONS            ==================================================================================

#define READ_ARGS(x) Serial.readBytes(command_array + 1, x + 1); if(command_array[x + 1] != '\n') {Serial.println("E_LENGTH"); while(Serial.read() != '\n') {} return;}

uint8_t command_array[64];
uint8_t command_index = 0;


void run_command() {
  if (!Serial.available()) {
    return;
  }

  command_array[0] = Serial.read();
  switch (command_array[0]) {
    case '0':
      READ_ARGS(0);
      Serial.println("Hello");
      break;
    case 'H':
      // Home x+z
      READ_ARGS(0);
      findHome();
      Serial.println("OK");
      break;
    case 'g':
      READ_ARGS(4);
      uint16_t to_coords[2];
      memcpy(to_coords, command_array + 1, 4);
      accelToAndWait(to_coords[0], to_coords[1]);
      Serial.println("OK");
      break;
    case 'G':
      READ_ARGS(1);
      if (command_array[1] < 0 || command_array[1] > 8) {
        Serial.println("E_ILLEG");
        break;
      }
      gear = command_array[1];
      Serial.println("OK");
      break;
    case 'P':
      READ_ARGS(1);
      steps_per_pixel = command_array[1];
      Serial.println("OK");
      break;
    case 'B':
      READ_ARGS(1);
      backlash = command_array[1];
      Serial.println("OK");
      break;
    case 'W':
      READ_ARGS(2);
      memcpy(&bitmap_width, command_array + 1, 2);
      Serial.println("OK");
      break;
    case 'b':
      READ_ARGS(1);
      draw_line(command_array[1] != 0);
      Serial.println("OK");
      break;
    case 'p':
      READ_ARGS(0);
      Serial.println("READY");
      Serial.readBytes(pixel_array, (bitmap_width + 7) / 8);
      Serial.println("OK");
      break;
    default:
      READ_ARGS(0);
      Serial.println("E_UNKNOWN");
      break;
  }
  memset(command_array, 0, sizeof(command_array));
  command_index = 0;
}

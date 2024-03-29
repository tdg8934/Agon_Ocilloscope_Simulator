Working folder for potential Agon Light 2 Oscilloscope
using ASD1115 16-bit ADC module over I2C protocal
Agon Light 2 GPIO pins 34 (+3.3vdc), 33 (GND), 30 (SCL), 29 (SDA)
Test with a potentiometer (10K?) with 3.3vdc, A0 (ADS module), GND
Make sure all files are in same directory on uSD card for Agon Light 2
On Agon Light 2:  >*bye    *load i2c_adc.bin    *run
Turning the potentiometer should show MSB and LSB values increasing or decreasing

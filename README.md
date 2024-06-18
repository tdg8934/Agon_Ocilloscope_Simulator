Working folder for potential Agon Light 2 Oscilloscope
using ASD1115 16-bit ADC module over I2C protocal

Agon Light 2 GPIO pins 34 (+3.3vdc), 33 (GND), 30 (SCL), 29 (SDA)

ADS1115 module:

VDD - 3.3vdc from Agon Light 2

GND - GND from Agon Light 2

SCL - SCL from Agon Light 2

SDA - SDA from Agon Light 2

ADDR - GND (so I2C address is $48)


Test with a potentiometer (10K?) with 3.3vdc, A0 (ADS module), GND

Make sure all files are in same directory on uSD card for Agon Light 2

On Agon Light 2:  >*bye    

*load i2c_adc.bin    

*run

Turning the potentiometer should show MSB and LSB values increasing or decreasing

https://helpfulcolin.com/xr2206-function-generator-kit-improved-instructions/

https://a.co/d/0HAAz3I



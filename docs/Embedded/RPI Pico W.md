Most Pico LED Blink examples will _NOT_ work on the Pico W onboard LED. As it turns out - this LED is connected to the Wireless chip and not the RP2040.

rp-hal, the Rust HAL, had an [experimental branch](https://github.com/rp-rs/rp-hal/issues/525) to make the onboard LED blink but it was never merged.

## rp-hal & rp-rs

The Rust projects for RPI Pico W still work _mostly_. Networking is still partial / not working. [The branch](https://github.com/jannic/rp-hal/tree/pico-w) remains unmerged in January 2024.
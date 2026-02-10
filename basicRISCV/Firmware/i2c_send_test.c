#include <stdint.h>
#include <stdio.h>

/* ===============================
 * I2C Master Base Address
 * =============================== */
#define I2C_BASE_ADDR   0x20000000UL

/* Register Offsets */
#define I2C_START       0x00
#define I2C_CLK_DIV     0x04
#define I2C_SLAVE_ADDR  0x08
#define I2C_TX_DATA     0x0C
#define I2C_RX_DATA     0x10
#define I2C_STATUS      0x14
#define I2C_MODE        0x18

/* Register Access */
#define I2C_REG(off) (*(volatile uint32_t *)(I2C_BASE_ADDR + (off)))

/* Polling helper: wait until DONE bit is set in STATUS */
#define I2C_STATUS_DONE_MASK 0x01

/* Simple delay */
static void delay(volatile uint32_t count)
{
    while (count--) {
        __asm__("nop");
    }
}

int main(void)
{
    uint32_t status = I2C_REG(I2C_STATUS);
    printf("Status: 0x%08X\n", status);
    /* -----------------------------
     * Program I2C registers
     * ----------------------------- */

    I2C_REG(I2C_CLK_DIV)    = 2;        // clk_div
    delay(10);
    I2C_REG(I2C_SLAVE_ADDR) = 0x55;     // slave address
    delay(10);
    I2C_REG(I2C_TX_DATA)    = 0xA6;     // data to send
    delay(10);
    I2C_REG(I2C_MODE)       = 0;        // 0 = transmit mode
    delay(10);

    /* -----------------------------
     * Start I2C transaction
     * ----------------------------- */
    I2C_REG(I2C_START) = 1;

    /* Optional: clear start if edge-triggered */
    // I2C_REG(I2C_START) = 0;

    /* Wait for transaction to complete */
    delay(10000);

    /* -----------------------------
     * Poll STATUS until transaction completes
     * ----------------------------- */
    do {
        status = I2C_REG(I2C_STATUS);
    } while ((status & I2C_STATUS_DONE_MASK) == 0);

    printf("I2C transaction completed. Status: 0x%08X\n", status);
    /* -----------------------------
     * Read back data (if RX mode)
     * ----------------------------- */
    uint32_t rxdata = I2C_REG(I2C_RX_DATA);

    while (1) {
        /* idle loop */
    }

    return 0;
}

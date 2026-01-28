bool TestA20()
{
    uint32_t* lowMem = (uint32_t*)0x500;
    *lowMem = 0xC0DE1234;

    uint32_t* highMem = (uint32_t*)0x100500;
    if (*highMem == *lowMem)
    {
        return false; // <- A20 is disabled
    }

    return true; // <- A20 is disabled
}
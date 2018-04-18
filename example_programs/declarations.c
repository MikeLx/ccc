
int main(int argc, char** argv)
{
    int x = 1;
    int y = x;
    int z = y + x;
    char* s = "abc";
    char t = 'f';
    {
      char t = 'g';
      char x = 'h';
    }
}

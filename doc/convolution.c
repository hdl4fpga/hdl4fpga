typedef int sample;

sample convolution (x, h, n)
sample x[];
sample h[];
int n;
{
	sample y;

	y = 0;
	for (int i = 0; i < 84; i++)
		y += h[i]*x[n-i];
	return y;
}


public abstract class FourierTransform{
  public final int NONE = 0;
  public final int HAMMING = 1;
  protected static final int LINAVG = 2;
  protected static final int LOGAVG = 3;
  protected static final int NOAVG = 4;
  protected static final float TWO_PI = (float) (2 * Math.PI);
  protected int timeSize;
  protected int sampleRate;
  protected float bandWidth;
  protected int whichWindow;
  protected float[] real;
  protected float[] imag;
  protected float[] spectrum;
  protected float[] averages;
  protected int whichAverage;
  protected int octaves;
  protected int avgPerOctave;
  FourierTransform(int ts, float sr)
  {
    timeSize = ts;
    sampleRate = (int)sr;
    bandWidth = (2f / timeSize) * ((float)sampleRate / 2f);
    noAverages();
    allocateArrays();
    whichWindow = NONE;
  }
  protected abstract void allocateArrays();

  protected void setComplex(float[] r, float[] i)
  {
    if (real.length != r.length && imag.length != i.length)
    {
      throw new IllegalArgumentException( "This won't work" );
    } else
    {
      System.arraycopy(r, 0, real, 0, r.length);
      System.arraycopy(i, 0, imag, 0, i.length);
    }
  }

  protected void fillSpectrum()
  {
    for (int i = 0; i < spectrum.length; i++)
    {
      spectrum[i] = (float) Math.sqrt(real[i] * real[i] + imag[i] * imag[i]);
    }

    if (whichAverage == LINAVG)
    {
      int avgWidth = (int) spectrum.length / averages.length;
      for (int i = 0; i < averages.length; i++)
      {
        float avg = 0;
        int j;
        for (j = 0; j < avgWidth; j++)
        {
          int offset = j + i * avgWidth;
          if (offset < spectrum.length)
          {
            avg += spectrum[offset];
          } else
          {
            break;
          }
        }
        avg /= j + 1;
        averages[i] = avg;
      }
    } else if (whichAverage == LOGAVG)
    {
      for (int i = 0; i < octaves; i++)
      {
        float lowFreq, hiFreq, freqStep;
        if (i == 0)
        {
          lowFreq = 0;
        } else
        {
          lowFreq = (sampleRate / 2) / (float) Math.pow(2, octaves - i);
        }
        hiFreq = (sampleRate / 2) / (float) Math.pow(2, octaves - i - 1);
        freqStep = (hiFreq - lowFreq) / avgPerOctave;
        float f = lowFreq;
        for (int j = 0; j < avgPerOctave; j++)
        {
          int offset = j + i * avgPerOctave;
          averages[offset] = calcAvg(f, f + freqStep);
          f += freqStep;
        }
      }
    }
  }

  public void noAverages()
  {
    averages = new float[0];
    whichAverage = NOAVG;
  }
 public void linAverages(int numAvg)
  {
    if (numAvg > spectrum.length / 2)
    {
      throw new IllegalArgumentException("The number of averages for this transform can be at most " + spectrum.length / 2 + ".");
    } else
    {
      averages = new float[numAvg];
    }
    whichAverage = LINAVG;
  }
 public void logAverages(int minBandwidth, int bandsPerOctave)
  {
    float nyq = (float) sampleRate / 2f;
    octaves = 1;
    while ((nyq /= 2) > minBandwidth)
    {
      octaves++;
    }
    avgPerOctave = bandsPerOctave;
    averages = new float[octaves * bandsPerOctave];
    whichAverage = LOGAVG;
  }
  public void window(int which)
  {
    if (which < 0 || which > 1)
    {
      throw new IllegalArgumentException("Invalid window type.");
    } else
    {
      whichWindow = which;
    }
  }

  protected void doWindow(float[] samples)
  {
    switch (whichWindow)
    {
    case HAMMING:
      hamming(samples);
      break;
    }
  }

  protected void hamming(float[] samples)
  {
    for (int i = 0; i < samples.length; i++)
    {
      samples[i] *= (0.54f - 0.46f * Math.cos(TWO_PI * i / (samples.length - 1)));
    }
  }

  public int timeSize()
  {
    return timeSize;
  }
  public int specSize()
  {
    return spectrum.length;
  }
  public float getBand(int i)
  {
    if (i < 0) i = 0;
    if (i > spectrum.length - 1) i = spectrum.length - 1;
    return spectrum[i];
  }
 public float getBandWidth()
  {
    return bandWidth;
  }
  public abstract void setBand(int i, float a);
  public abstract void scaleBand(int i, float s);
 public int freqToIndex(float freq)
  {
   if (freq < getBandWidth() / 2) return 0;
    if (freq > sampleRate / 2 - getBandWidth() / 2) return spectrum.length - 1;
    float fraction = freq / (float) sampleRate;
    int i = Math.round(timeSize * fraction);
    return i;
  }
 public float indexToFreq(int i)
  {
     float bw = getBandWidth();
    // special case: the width of the first bin is half that of the others.
    //               so the center frequency is a quarter of the way.
    if ( i == 0 ) return bw * 0.25f;
    // special case: the width of the last bin is half that of the others.
    if ( i == spectrum.length - 1 ) 
    {
      float lastBinBeginFreq = (sampleRate / 2) - (bw / 2);
      float binHalfWidth = bw * 0.25f;
      return lastBinBeginFreq + binHalfWidth;
    }
    // the center frequency of the ith band is simply i*bw
    // because the first band is half the width of all others.
    // treating it as if it wasn't offsets us to the middle 
    // of the band.
    return i*bw;
  }
  public float getAverageCenterFrequency(int i)
  {
    if ( whichAverage == LINAVG )
    {
      int avgWidth = (int) spectrum.length / averages.length;
      int centerBinIndex = i*avgWidth + avgWidth/2;
      return indexToFreq(centerBinIndex);
    } else if ( whichAverage == LOGAVG )
    {
      int octave = i / avgPerOctave;
      int offset = i % avgPerOctave;
      float lowFreq, hiFreq, freqStep;
      if (octave == 0)
      {
        lowFreq = 0;
      } else
      {
        lowFreq = (sampleRate / 2) / (float) Math.pow(2, octaves - octave);
      }
      hiFreq = (sampleRate / 2) / (float) Math.pow(2, octaves - octave - 1);
     freqStep = (hiFreq - lowFreq) / avgPerOctave;
     float f = lowFreq + offset*freqStep;
     return f + freqStep/2;
    }

    return 0;
  }

 public float getFreq(float freq)
  {
    return getBand(freqToIndex(freq));
  }

  public void setFreq(float freq, float a)
  {
    setBand(freqToIndex(freq), a);
  }

  
  public void scaleFreq(float freq, float s)
  {
    scaleBand(freqToIndex(freq), s);
  }
  public int avgSize()
  {
    return averages.length;
  }

  public float getAvg(int i)
  {
    float ret;
    if (averages.length > 0)
      ret = averages[i];
    else
      ret = 0;
    return ret;
  }
  public float calcAvg(float lowFreq, float hiFreq)
  {
    int lowBound = freqToIndex(lowFreq);
    int hiBound = freqToIndex(hiFreq);
    float avg = 0;
    for (int i = lowBound; i <= hiBound; i++)
    {
      avg += spectrum[i];
    }
    avg /= (hiBound - lowBound + 1);
    return avg;
  }

  public abstract void forward(float[] buffer);

 public void forward(float[] buffer, int startAt)
  {
    if ( buffer.length - startAt < timeSize )
    {
      throw new IllegalArgumentException( "FourierTransform.forward: not enough samples in the buffer between " + startAt + " and " + buffer.length + " to perform a transform." );
    }

    float[] section = new float[timeSize];
    System.arraycopy(buffer, startAt, section, 0, section.length);
    forward(section);
  }
  public abstract void inverse(float[] buffer);
  public void inverse(float[] freqReal, float[] freqImag, float[] buffer)
  {
    setComplex(freqReal, freqImag);
    inverse(buffer);
  }
  public float[] getSpectrum( )
  {
    return spectrum;
  }

 public float[] getRealPart( )
  {
    return real;
  }

   public float[] getImaginaryPart( )
  {
    return imag;
  }
}

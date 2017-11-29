/*
 * This file provided by Facebook is for non-commercial testing and evaluation
 * purposes only.  Facebook reserves all rights not expressly granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
// Coming from: https://github.com/facebook/fresco/blob/master/samples/showcase/src/main/java/com/facebook/fresco/samples/showcase/

package com.facebook.react.views.imagehelper.svg;

import android.content.Context;
import android.os.Build;
import android.support.annotation.Nullable;
import com.facebook.drawee.backends.pipeline.DraweeConfig;
import com.facebook.react.views.imagehelper.svg.SvgDecoderUtil;
import com.facebook.imagepipeline.decoder.ImageDecoderConfig;

/**
 * Helper class to add custom SVG decoder
 */
public class CustomImageFormatConfigurator {

  @Nullable
  public static ImageDecoderConfig createImageDecoderConfig(Context context) {
    ImageDecoderConfig.Builder config = ImageDecoderConfig.newBuilder();

    config.addDecodingCapability(
        SvgDecoderUtil.SVG_FORMAT,
        new SvgDecoderUtil.SvgFormatChecker(),
        new SvgDecoderUtil.SvgDecoder());

    return config.build();
  }

  public static void addCustomDrawableFactories(
      Context context,
      DraweeConfig.Builder draweeConfigBuilder) {

    draweeConfigBuilder.addCustomDrawableFactory(new SvgDecoderUtil.SvgDrawableFactory());
  }
}

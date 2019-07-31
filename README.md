# Unity-Miscellaneous-Shaders
一个管理小shader的仓库，慢慢添加。

## Update 2018/1/1 GlassDragon
#### Description：
run
![](https://images2017.cnblogs.com/blog/686199/201801/686199-20180102084623971-1987497628.png)


## Update 2017/12/3：Explosion and sand effect
#### Description：

run and click the model

![](http://images.cnblogs.com/cnblogs_com/murongxiaopifu/662093/o_201712011144311512143071399_small.gif)

Blog:

[Using the geometry shader to achieve model explosion effect
](http://chenjd.xyz/2019/07/31/Explode-and-sand-the-model-with-the-geometry-shader/)

## Update 2017/11/23：更新一个斯坦福兔子生成皮毛的demo
#### Description：
Using the Geometry Shader to generate fur on GPU. 
![](http://images.cnblogs.com/cnblogs_com/murongxiaopifu/662093/o_QQ%e6%88%aa%e5%9b%be20171123130550.png)
![](http://upload-images.jianshu.io/upload_images/1372105-5e7cdcf5081a0625.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## Update 2017/11/23：更新一个雪地印痕的效果小demo。

![](http://images.cnblogs.com/cnblogs_com/murongxiaopifu/662093/o_3c.gif)



## 小随笔：写一个基于几何生成方法的描边效果

## 0x00 前言
进入金秋九月之后，周末参加的社区活动反而多了起来。因此不像之前一样有富余的时间来写一些长文了，在考虑写点什么的时候突然想到了上一篇文章[《利用GPU实现翻页效果》](https://zhuanlan.zhihu.com/p/28836892)中利用shader实现了一个有趣的翻书的效果。那么这篇文章不妨也来效仿一下写一个shader来实现某种效果，只不过篇幅上可能更短、效果更简单，当然写作的时间也更碎片化了，所以《小随笔》似乎是一个不错的标题。

## 0x01 先来点理论知识
本文要实现的内容是一个很常见的描边效果。![](http://upload-images.jianshu.io/upload_images/1372105-d364ddc951258cd3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
（本文的模型来自：RTS Mini Legion Lich）
实现的思路来自《Real Time Rendering》的相关章节，即基于几何生成方法的描边。相关的理论内容已经有不少文章都提到过，这里简单概况一下就是在绘制模型时用两个pass，第一遍正常绘制模型；第二遍绘制则要将模型**正面剔除**——正面剔除的原因在下面的演示中我会告诉各位原因——接着在vs中修改顶点位置，将顶点沿着法线方向膨胀一定距离，然后在fs中将模型用纯色输出即可。 

![](http://upload-images.jianshu.io/upload_images/1372105-18c708d0f41e1f9c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
（图片来自：【翻译】西川善司「实验做出的游戏图形」「GUILTY GEAR Xrd -SIGN-」中实现的「纯卡通动画的实时3D图形」的秘密，前篇（2））
## 0x02 再来点实际操作
好了，现在就让我们来实现这个效果吧。
首先我们显然总共需要两个pass，但是我们先实现一个pass，将模型正常的绘制出来。

		// 第一个pass用来渲染正常的模型
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		
经过这次绘制，屏幕上出现了正常的模型。

![QQ截图20170913221207.png](http://upload-images.jianshu.io/upload_images/1372105-d21635a39949625f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

OK，下面第二个pass要来了。
由于这次我们需要使用法线信息，所以我们可以直接使用Unity内建的appdata_base作为vs的输入，它包含了顶点的法线信息。而由于这次vs和fs之间并没有数据的传递，因此vs只需要输出位置到SV_POSITION，而fs只需要输出纯色到SV_Target即可。

			float4 vert(appdata_base v) : SV_POSITION
			{
				...
			}

			fixed4 frag() : SV_Target {
				return _OutlineColor;
			}

除此之外，在vs中我们不能直接使用在model空间的法线信息，因此还要将顶点的法线信息从model空间转换到clip空间。

				float3 normal = mul((float3x3) UNITY_MATRIX_MVP, v.normal);


然后将顶点沿着法线方向膨胀一定距离:

				pos.xy += _OutlineFactor * normal.xy;

嗯。现在的效果有点赞了。
![2b.gif](http://upload-images.jianshu.io/upload_images/1372105-789582d4e9737f05.gif?imageMogr2/auto-orient/strip)

最后再来看看为什么要打开正面剔除，如果没有正面剔除我们将看到的是一个颜色错误的模型。
就像下面这样：
![QQ截图20170913224809.png](http://upload-images.jianshu.io/upload_images/1372105-065dde99c095b203.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

好了，到此一个常见而又简单的效果就实现了。
祝各位早安~

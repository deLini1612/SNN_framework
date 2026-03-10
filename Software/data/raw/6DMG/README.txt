1. Each .mat file is named as g[XX]_[YY]_t[ZZ].mat:
[XX]: gesture index
[YY]: tester ID
[ZZ]: trial index

2. Each .mat file contains 3 matrices:
 - gest: (14 x n, n samples), the order as defined in GestureDef.h
    | timestamp1  ...    timestampn |
    | pos1.x      ...    posn.x     |
    | pos1.y      ...    posn.y     |
    | pos1.z      ...    posn.z     |
    | ori1.w      ...    orin.w     |
    | ori1.x      ...    orin.x     |
    | ori1.y      ...    orin.y     |
    | ori1.z      ...    orin.z     |
    | acc1.x      ...    accn.x     |
    | acc1.y      ...    accn.y     |
    | acc1.z      ...    accn.z     |
    | w1.yaw      ...    wn.yaw     |
    | w1.pitch    ...    wn.pitch   |
    | w1.roll     ...    wn.roll    |
      
 - bias:  (3 x 1), the bias of the angular speeds (from the gyro)
    | yaw   |
    | pitch |
    | roll  |

 - noise: (3 x 1), the std of bias of the angular speeds (from the gyro)
    | yaw   |
    | pitch |
    | roll  |

3. The gesuter index <==> gesture name (as in GestureDef.h)
   // swipe
   00	SWIPE_RIGHT,
   01	SWIPE_LEFT,
   02	SWIPE_UP,
   03	SWIPE_DOWN,
   04	SWIPE_UPRIGHT,
   05	SWIPE_UPLEFT,
   06	SWIPE_DOWNRIGHT,
   07	SWIPE_DOWNLEFT,

   // back & forth
   08	POKE_RIGHT,
   09	POKE_LEFT,
   10	POKE_UP,
   11	POKE_DOWN,

   // others
   12   V_SHAPE,
   13	X_SHAPE,
   14	CIR_HOR_CLK,
   15	CIR_HOR_CCLK,
   16	CIR_VER_CLK,
   17	CIR_VER_CCLK,
   18	TWIST_CLK,
   19	TWITS_CCLK,

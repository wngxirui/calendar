# calendar
需要两个状态机，分别控制不同数据设置与显示之间的切换和设置数据时对哪个数据的选中之间的切换。
不管在任何状态下，时间与日期需要在后台持续刷新，因此实时的年月日与时分秒需在单独的always块中，以保证数据的更新不间断。
通过六个LED的闪烁判断整点和闹钟设置的时刻到来。
用一个拨码开关控制是否设置闹钟，为一表示在闹钟激活，即LED会在设置的时刻到来之时闪烁，为零则反之。
当闹钟时刻到来，通过将拨码开关置零实现闹钟的关闭，即LED由闪烁变暗。
在对日期和时间的设置和计数时，通过代码中的条件判断保证数据的合理性，如不同月份有不同的天数，分钟与秒都在60以内。
调用数码管显示模块实现数字的实时显示。

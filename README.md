# LBRefreshing
A basic view for refreshing.
Just addSubview to UIScrollview or its subclass & set the callBack, the refreshingview will invoke the callBack when refreshing animation starts.

# Methods
"startRefreshing()" invoked to start the refreshing animation.

"endRefreshing()" invoked to end the refreshing animation.


"init(frame: CGRect,CallBack: () -> Void)" invoked to create the view, the first parameter will be ignored in the implement.

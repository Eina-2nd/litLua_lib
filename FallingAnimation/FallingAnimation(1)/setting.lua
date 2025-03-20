require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.content.*"
import "android.view.WindowManager"
import "android.content.IntentFilter"
import "android.content.res.Configuration"



layout={
LinearLayout;
  layout_width="match_parent";
  layout_height="match_parent";
  orientation="vertical";
  {
  LinearLayout;
    layout_width="match_parent";
    layout_height="wrap_content";
    orientation="vertical";
    {
    LinearLayout;
      gravity="center";
      layout_height="match_parent";
      layout_marginTop="10dp";
      layout_marginLeft="10dp";
      orientation="horizontal";
      {
      ImageView;
        layout_width="26dp";
        src="res/ic_arrow_back_black_24dp.png";
        layout_height="26dp";
        id="back_img";
        };
        {
      TextView;
        textColor="#424242";
        text="Settings";
        layout_marginLeft="10dp";
        textSize="20sp";
        layout_marginTop="3dp";
        };
      };
      --此处添加更多控件
    };
  };

  activity.setTheme(android.R.style.Theme_Material_Light_NoActionBar)
  activity.setContentView(loadlayout(layout))

  --¶屏幕方向
  local filter = IntentFilter()
  filter.addAction("android.intent.action.CONFIGURATION_CHANGED")
  -- 注册广播接收器
  activity.registerReceiver(
  BroadcastReceiver({
  onReceive = function(context, intent)
  -- 获取当前屏幕方向
  local orientation = activity.getResources().getConfiguration().orientation
  if orientation == Configuration.ORIENTATION_LANDSCAPE then
  function 全屏()
  window = activity.getWindow();
  window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN|View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
  window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
  xpcall(function()
  lp = window.getAttributes();
  lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
  window.setAttributes(lp);
  end,
  function(e)
  end)
  end
  全屏()
 elseif orientation == Configuration.ORIENTATION_PORTRAIT then
  function 恢复默认状态()
  window = activity.getWindow()
  window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE) -- 恢复状态栏和导航栏
  window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN) -- 清除全屏标志
  xpcall(function()
  lp = window.getAttributes()
  lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT
  window.setAttributes(lp)
  end,
  function(e)
  print("恢复默认状态出错: " .. tostring(e))
  end)
  end
  恢复默认状态()
  end
  end
  }), filter)

  --¶返回
  back_img.onClick= function()
  activity.finish()
  end


  --更多功能...
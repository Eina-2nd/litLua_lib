require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.content.*"
import "android.net.Uri"
import "java.io.*"
import "com.mslh.LeafView"
import "android.content.pm.ActivityInfo"
import "android.graphics.Color"
import "android.graphics.drawable.GradientDrawable"
import "android.graphics.Typeface"
import "android.view.WindowManager"
import "android.content.IntentFilter"
import "android.content.res.Configuration"

activity.setTheme(android.R.style.Theme_Material_Light_NoActionBar)

--¶屏幕方向的处理
-- 创建 IntentFilter 对象
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
activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR)

--¶常量定义
local PREFS_NAME = "my_app_prefs"
local IMAGE_KEY = "saved_image_path"
local SAVE_FOLDER = activity.getExternalFilesDir("images").toString() .. "/"
local DEFAULT_IMAGE = "u=2253254292,4190655294&fm=253&fmt=auto&app=1.jpg" -- 默认图片文件名

activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);


-- ¶视图和布局
activity.setContentView(loadlayout(
{
  FrameLayout,
  layout_width="match_parent",
  layout_height="match_parent",
  id="l",
  {
    ImageView,
    id="ivPreview",
    layout_width="match_parent",
    layout_height="match_parent",
    scaleType="centerCrop"
  },
  {
    CardView;
    layout_gravity='center';
    layout_marginBottom='100dp';
    elevation='5';
    layout_width='180dp';
    CardBackgroundColor='#ffffffff';
    layout_height='90dp';
    radius='15dp';
    {
      TextView;
      layout_width='fill';
      layout_height='fill';
      gravity='center';
      textColor='#fff42e91';
      text='年份';
      textSize='20dp';
      id="年底";
      layout_marginBottom='30dp';

    };
    {
      TextView;
      layout_width='fill';
      layout_height='fill';
      gravity='center';
      textColor='#fff42e91';
      text='时间';
      id="时分秒";
      textSize='24dp';
      layout_marginTop='30dp';
    };
  };
  {
    LinearLayout;
    layout_width="wrap_content";
    layout_height="wrap_content";
    layout_gravity="center";
    --[[    
   {
      Button;
      text="设置时间";
      id="btndjs";
    }; 
]]
  };
  {
    Button;
    id="btnChoose";
    text="自定义背景图片";
    layout_width="wrap_content";
    layout_height="wrap_content";
    layout_gravity="bottom|center";
  };
  {
    ImageView;
    src="res/ic_settings_black_24dp.png";
    layout_width="28dp";
    layout_height="28dp";
    layout_margin="10dp";
    id="stt";
  };
}))

--¶落花动画
h=activity.getLuaPath(tostring(1))
u=h..".png"
l.addView(LeafView(this,u))

--¶Button的样式
--btnChoose的按钮样式
InsideColor = Color.parseColor("#250d0132")
radiu = 80
drawable = GradientDrawable()
drawable.setShape(GradientDrawable.RECTANGLE)
--设置填充色
drawable.setColor(InsideColor)
--设置圆角 : 左上 右上 右下 左下
drawable.setCornerRadii({4, 4, 4, 4, 4, 4, 4, 4});
--设置边框 : 宽度 颜色
drawable.setStroke(2, Color.parseColor("#610f1412"))
btnChoose.setBackgroundDrawable(drawable)

--[[
--如上同理的btndjs按钮样式：
InsideColorr = Color.parseColor("#F0F0F0B3")
radiu = 80
draw = GradientDrawable()
draw.setShape(GradientDrawable.RECTANGLE)
--设置填充色
draw.setColor(InsideColorr)
--设置圆角 : 左上 右上 右下 左下
draw.setCornerRadii({20, 20, 20, 20, 20, 20, 20, 20});
--设置边框 : 宽度 颜色
draw.setStroke(2, Color.parseColor("#610f1412"))
btndjs.setBackgroundDrawable(draw)
]]

--§自定义背景图片
-- 设置默认图片
ivPreview.setImageBitmap(loadbitmap(DEFAULT_IMAGE))

-- 创建保存目录
local saveDir = File(SAVE_FOLDER)
if not saveDir.exists() then
  saveDir.mkdirs()
end

-- 加载保存的图片路径
local prefs = activity.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
local savedPath = prefs.getString(IMAGE_KEY, nil)

-- 如果存在已保存图片则加载
if savedPath and File(savedPath).exists() then
  ivPreview.setImageBitmap(loadbitmap(savedPath))
end

-- 图片选择回调
function onActivityResult(requestCode, resultCode, intent)
  if requestCode == 1001 and resultCode == Activity.RESULT_OK then
    if intent then
      local uri = intent.getData()
      if uri then
        -- 获取图片路径
        local cursor = activity.getContentResolver().query(uri, { "_data" }, nil, nil, nil)
        if cursor then
          cursor.moveToFirst()
          local path = cursor.getString(0)
          cursor.close()
          -- 显示图片
          ivPreview.setImageBitmap(loadbitmap(path))
          -- 保存图片到指定目录
          local newFile = File(SAVE_FOLDER .. "background_" .. os.time() .. ".jpg")
          copyFile(File(path), newFile)
          -- 保存路径到SharedPreferences
          prefs.edit()
          .putString(IMAGE_KEY, newFile.getAbsolutePath())
          .apply()
        end
      end
    end
  end
end

-- 文件复制函数
function copyFile(src, dst)
  local inStream = FileInputStream(src)
  local outStream = FileOutputStream(dst)
  local buffer = byte[1024]

  -- Lua读取循环
  while true do
    local len = inStream.read(buffer)
    if len == -1 or len == 0 then -- 增加-1判断适配不同实现
      break
    end
    outStream.write(buffer, 0, len)
  end
  inStream.close()
  outStream.close()
end

btnChoose.onClick = function()
  local intent = Intent(Intent.ACTION_PICK)
  intent.setType("image/*")
  activity.startActivityForResult(intent, 1001)
end

stt.onClick = function()
  activity.newActivity("setting")
end

--¶时间
function 月份()
  年份()
end

function 年份()
  年底.setText(os.date("%Y年%m月%d日"))--获取当前系统时间
end

function 刷新()
  require "import"
  while true do--执行循环命令
    Thread.sleep(100)--延迟执行
    call("月份")
  end
end

thread(刷新)--运行线程,循环刷新时间

--本地系统时间
function 时间()
  时间秒()
end

function 时间秒()
  时分秒.setText(os.date("%H:%M:%S"))--获取当前系统时间
end

function 刷新()
  require "import"
  while true do--执行循环命令
    Thread.sleep(100)--延迟执行
    call("时间")
  end
end

thread(刷新)--运行线程,循环刷新时间

时分秒.getPaint().setTypeface(Typeface.SANS_SERIF)
--Typeface.MONOSPACE
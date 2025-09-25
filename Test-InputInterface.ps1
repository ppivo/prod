# Input interface testing function. Only to be run in sandbox/testlab without public access!
#
# Usage: Copy this whole code and paste to powershell to initilazie the function. To start the input interface test, type Test-InputInterface and press Enter
# Parameters: None :D 
# Script waits 2 minutes from last user activity to start input interface test: 
# Moves mouse 2px right and left. 
# Presses Ctrl-Shift-F12 for more fun. 
# waits 2 min to repeat the above shit until user hits the key/mouse

# ------- important shit! ------
# It's function is all quitet. Stop it with Ctrl-C and call again from the same window when needed 
# Always make sure to stop the testing during your lunch break or outside business hours!
# Peace and love to all wintel admins, globally & internationally

# PePi 2025

function Global:Test-InputInterface {

Add-Type -Namespace Win32 -Name UserInput -MemberDefinition @"
    [DllImport("user32.dll")] public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
    [DllImport("user32.dll")] public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
    [StructLayout(LayoutKind.Sequential)] public struct LASTINPUTINFO { public uint cbSize; public uint dwTime;}
    [StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public InputUnion u;}
    [StructLayout(LayoutKind.Explicit)] public struct InputUnion { [FieldOffset(0)] public MOUSEINPUT mi; [FieldOffset(0)] public KEYBDINPUT ki;}
    [StructLayout(LayoutKind.Sequential)] public struct MOUSEINPUT { public int dx; public int dy; public uint mouseData; public uint dwFlags; public uint time; public IntPtr dwExtraInfo;}
    [StructLayout(LayoutKind.Sequential)] public struct KEYBDINPUT { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo;}
    public const uint INPUT_MOUSE = 0; public const uint INPUT_KEYBOARD = 1;
    public const uint MOUSEEVENTF_MOVE = 0x0001;
    public const uint KEYEVENTF_KEYUP = 0x0002;
    public const ushort VK_CONTROL = 0x11; public const ushort VK_SHIFT = 0x10; public const ushort VK_F12 = 0x7B;
    public static uint GetIdleTime() { LASTINPUTINFO info = new LASTINPUTINFO(); info.cbSize = (uint)Marshal.SizeOf(info); GetLastInputInfo(ref info); return ((uint)Environment.TickCount - info.dwTime); }
    public static void SendKeyCombo() {
        INPUT[] inputs = new INPUT[6];
        inputs[0] = new INPUT {type=INPUT_KEYBOARD, u=new InputUnion{ki=new KEYBDINPUT{wVk=VK_CONTROL}}};
        inputs[1] = new INPUT {type=INPUT_KEYBOARD, u=new InputUnion{ki=new KEYBDINPUT{wVk=VK_SHIFT}}};
        inputs[2] = new INPUT {type=INPUT_KEYBOARD, u=new InputUnion{ki=new KEYBDINPUT{wVk=VK_F12}}};
        inputs[3] = new INPUT {type=INPUT_KEYBOARD, u=new InputUnion{ki=new KEYBDINPUT{wVk=VK_F12, dwFlags=KEYEVENTF_KEYUP}}};
        inputs[4] = new INPUT {type=INPUT_KEYBOARD, u=new InputUnion{ki=new KEYBDINPUT{wVk=VK_SHIFT, dwFlags=KEYEVENTF_KEYUP}}};
        inputs[5] = new INPUT {type=INPUT_KEYBOARD, u=new InputUnion{ki=new KEYBDINPUT{wVk=VK_CONTROL, dwFlags=KEYEVENTF_KEYUP}}};
        SendInput(6, inputs, Marshal.SizeOf(typeof(INPUT)));
    }
    public static void MoveMouse(int dx, int dy) {
        INPUT[] inputs = new INPUT[1];
        inputs[0] = new INPUT { type=INPUT_MOUSE, u=new InputUnion{mi=new MOUSEINPUT{dx=dx, dy=dy, dwFlags=MOUSEEVENTF_MOVE}}};
        SendInput(1, inputs, Marshal.SizeOf(typeof(INPUT)));
    }
"@ -ReferencedAssemblies 'System.Runtime.InteropServices'

while($true){
    while([Win32.UserInput]::GetIdleTime() -lt 120000) { Start-Sleep -Seconds 1 }
    [Win32.UserInput]::MoveMouse(-2,0); Start-Sleep -Seconds 1
    [Win32.UserInput]::MoveMouse(2,0); Start-Sleep -Seconds 1
    [Win32.UserInput]::SendKeyCombo()
    Start-Sleep -Seconds 116
}
} # end of fn Test-InputInterface


#!/usr/bin/env python3
# ============================================================
#  S1Bs1stem CONTROL CENTER - GUI Control Panel
#  Version: 1.0.0
#  Dependencies: python3, python3-tk, python3-yaml
#  ============================================================

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import os
import yaml
import threading
from datetime import datetime

class S1BControlCenter:
    """Main GUI Application for S1Bs1stem Control Center"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("S1Bs1stem Control Center v1.0")
        self.root.geometry("1000x700")
        self.root.configure(bg='#1e1e2e')
        
        # Colors (Catppuccin Mauve theme)
        self.colors = {
            'bg': '#1e1e2e',
            'bg_light': '#302d41',
            'mauve': '#cba6f7',
            'green': '#a6e3a1',
            'red': '#f38ba8',
            'yellow': '#f9e2af',
            'blue': '#89b4fa',
            'text': '#cdd6f4',
            'text_dim': '#6c7086'
        }
        
        # Load configuration
        self.config = self.load_config()
        
        # Setup UI
        self.setup_styles()
        self.create_menu()
        self.create_header()
        self.create_notebook()
        self.create_status_bar()
        
        # Auto-refresh status
        self.refresh_status()
    
    def load_config(self):
        """Load UI configuration"""
        config_path = os.path.expanduser("~/.local/s1barch/ui/ui_config.yaml")
        default_config = {
            'theme': 'catppuccin_mauve',
            'auto_refresh': True,
            'refresh_interval': 5,
            'tabs': ['System', 'Workflows', 'Display', 'Audio', 'Network']
        }
        
        try:
            if os.path.exists(config_path):
                with open(config_path, 'r') as f:
                    return yaml.safe_load(f)
        except Exception as e:
            print(f"Error loading config: {e}")
        
        return default_config
    
    def setup_styles(self):
        """Configure ttk styles"""
        style = ttk.Style()
        style.theme_use('clam')
        
        # Configure colors
        style.configure('TNotebook', background=self.colors['bg'], tabmargins=[2, 5, 2, 0])
        style.configure('TNotebook.Tab', 
                       background=self.colors['bg_light'],
                       foreground=self.colors['text'],
                       padding=[15, 5],
                       font=('JetBrains Mono', 10))
        style.map('TNotebook.Tab',
                 background=[('selected', self.colors['mauve'])],
                 foreground=[('selected', self.colors['bg'])])
        
        style.configure('TFrame', background=self.colors['bg'])
        style.configure('TButton',
                       background=self.colors['mauve'],
                       foreground=self.colors['bg'],
                       padding=10,
                       font=('JetBrains Mono', 10, 'bold'))
        style.map('TButton',
                 background=[('active', self.colors['blue'])])
        
        style.configure('TLabel',
                       background=self.colors['bg'],
                       foreground=self.colors['text'],
                       font=('JetBrains Mono', 10))
    
    def create_menu(self):
        """Create menu bar"""
        menubar = tk.Menu(self.root, bg=self.colors['bg'], fg=self.colors['text'])
        self.root.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0, bg=self.colors['bg'], fg=self.colors['text'])
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Refresh", command=self.refresh_status)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        
        # Tools menu
        tools_menu = tk.Menu(menubar, tearoff=0, bg=self.colors['bg'], fg=self.colors['text'])
        menubar.add_cascade(label="Tools", menu=tools_menu)
        tools_menu.add_command(label="Run ORCHESTRA", command=self.run_orchestra)
        tools_menu.add_command(label="System Info", command=self.show_system_info)
        tools_menu.add_separator()
        tools_menu.add_command(label="Clear Logs", command=self.clear_logs)
        
        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0, bg=self.colors['bg'], fg=self.colors['text'])
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="Documentation", command=self.open_docs)
        help_menu.add_command(label="About", command=self.show_about)
    
    def create_header(self):
        """Create header with logo and system info"""
        header = tk.Frame(self.root, bg=self.colors['bg_light'], height=80)
        header.pack(fill='x', padx=10, pady=10)
        header.pack_propagate(False)
        
        # Title
        title = tk.Label(header,
                        text="🚀 S1Bs1stem Control Center",
                        bg=self.colors['bg_light'],
                        fg=self.colors['mauve'],
                        font=('JetBrains Mono', 20, 'bold'))
        title.pack(side='left', padx=20, pady=20)
        
        # Quick actions
        actions_frame = tk.Frame(header, bg=self.colors['bg_light'])
        actions_frame.pack(side='right', padx=20)
        
        tk.Button(actions_frame,
                 text="⚡ Quick Setup",
                 command=self.quick_setup,
                 bg=self.colors['green'],
                 fg=self.colors['bg'],
                 font=('JetBrains Mono', 10, 'bold'),
                 padx=15,
                 pady=5).pack(side='left', padx=5)
        
        tk.Button(actions_frame,
                 text="🔄 Refresh",
                 command=self.refresh_status,
                 bg=self.colors['blue'],
                 fg=self.colors['bg'],
                 font=('JetBrains Mono', 10, 'bold'),
                 padx=15,
                 pady=5).pack(side='left', padx=5)
    
    def create_notebook(self):
        """Create tabbed interface"""
        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(fill='both', expand=True, padx=10, pady=5)
        
        # Create tabs
        self.create_system_tab()
        self.create_workflows_tab()
        self.create_display_tab()
        self.create_audio_tab()
        self.create_network_tab()
    
    def create_system_tab(self):
        """System monitoring and control tab"""
        system_frame = ttk.Frame(self.notebook)
        self.notebook.add(system_frame, text=" System ")
        
        # System Status Section
        status_frame = tk.LabelFrame(system_frame,
                                    text=" System Status ",
                                    bg=self.colors['bg'],
                                    fg=self.colors['mauve'],
                                    font=('JetBrains Mono', 12, 'bold'),
                                    padx=10,
                                    pady=10)
        status_frame.pack(fill='x', padx=10, pady=10)
        
        # System info labels
        self.sys_labels = {}
        info_items = [
            ('OS', 'os_info'),
            ('Kernel', 'kernel_info'),
            ('Uptime', 'uptime_info'),
            ('Memory', 'memory_info'),
            ('Disk', 'disk_info'),
            ('CPU', 'cpu_info')
        ]
        
        for i, (label, key) in enumerate(info_items):
            tk.Label(status_frame,
                    text=f"{label}:",
                    bg=self.colors['bg'],
                    fg=self.colors['text_dim'],
                    font=('JetBrains Mono', 10)).grid(row=i, column=0, sticky='w', padx=5, pady=2)
            
            self.sys_labels[key] = tk.Label(status_frame,
                                           text="Loading...",
                                           bg=self.colors['bg'],
                                           fg=self.colors['text'],
                                           font=('JetBrains Mono', 10))
            self.sys_labels[key].grid(row=i, column=1, sticky='w', padx=5, pady=2)
        
        # System Actions
        actions_frame = tk.LabelFrame(system_frame,
                                     text=" System Actions ",
                                     bg=self.colors['bg'],
                                     fg=self.colors['mauve'],
                                     font=('JetBrains Mono', 12, 'bold'),
                                     padx=10,
                                     pady=10)
        actions_frame.pack(fill='x', padx=10, pady=10)
        
        buttons = [
            ("🧹 Clean System", self.clean_system, self.colors['yellow']),
            ("💾 Create Snapshot", self.create_snapshot, self.colors['blue']),
            ("🔄 Restore Snapshot", self.restore_snapshot, self.colors['mauve']),
            ("📊 View Logs", self.view_logs, self.colors['green'])
        ]
        
        for i, (text, command, color) in enumerate(buttons):
            btn = tk.Button(actions_frame,
                           text=text,
                           command=command,
                           bg=color,
                           fg=self.colors['bg'],
                           font=('JetBrains Mono', 10, 'bold'),
                           padx=15,
                           pady=8)
            btn.grid(row=i//2, column=i%2, padx=5, pady=5, sticky='ew')
    
    def create_workflows_tab(self):
        """Workflows management tab"""
        workflows_frame = ttk.Frame(self.notebook)
        self.notebook.add(workflows_frame, text=" Workflows ")
        
        # Available Workflows
        wf_frame = tk.LabelFrame(workflows_frame,
                                text=" Available Workflows ",
                                bg=self.colors['bg'],
                                fg=self.colors['mauve'],
                                font=('JetBrains Mono', 12, 'bold'))
        wf_frame.pack(fill='both', expand=True, padx=10, pady=10)
        
        workflows = [
            ("💻 Local Development", "ws-local", "Optimized for local coding"),
            ("🌐 Remote Server", "ws-remote", "SSH and remote management"),
            ("✍️ Deep Write", "ws-write", "Focus mode for writing"),
            ("🎯 Red Team", "ws-redteam", "Security testing environment")
        ]
        
        for i, (name, cmd, desc) in enumerate(workflows):
            frame = tk.Frame(wf_frame, bg=self.colors['bg_light'], padx=10, pady=10)
            frame.pack(fill='x', padx=5, pady=5)
            
            tk.Label(frame,
                    text=name,
                    bg=self.colors['bg_light'],
                    fg=self.colors['text'],
                    font=('JetBrains Mono', 12, 'bold')).pack(anchor='w')
            
            tk.Label(frame,
                    text=desc,
                    bg=self.colors['bg_light'],
                    fg=self.colors['text_dim'],
                    font=('JetBrains Mono', 9)).pack(anchor='w')
            
            tk.Button(frame,
                     text="Launch",
                     command=lambda c=cmd: self.launch_workflow(c),
                     bg=self.colors['green'],
                     fg=self.colors['bg'],
                     font=('JetBrains Mono', 9, 'bold')).pack(side='right')
    
    def create_display_tab(self):
        """Display and wallpaper management tab"""
        display_frame = ttk.Frame(self.notebook)
        self.notebook.add(display_frame, text=" Display ")
        
        # Brightness Control
        brightness_frame = tk.LabelFrame(display_frame,
                                        text=" Brightness Control ",
                                        bg=self.colors['bg'],
                                        fg=self.colors['mauve'],
                                        font=('JetBrains Mono', 12, 'bold'))
        brightness_frame.pack(fill='x', padx=10, pady=10)
        
        self.brightness_scale = tk.Scale(brightness_frame,
                                        from_=0,
                                        to=100,
                                        orient='horizontal',
                                        bg=self.colors['bg'],
                                        fg=self.colors['text'],
                                        highlightthickness=0,
                                        command=self.set_brightness)
        self.brightness_scale.set(50)
        self.brightness_scale.pack(fill='x', padx=10, pady=10)
        
        # Wallpaper Controls
        wp_frame = tk.LabelFrame(display_frame,
                                text=" Wallpaper ",
                                bg=self.colors['bg'],
                                fg=self.colors['mauve'],
                                font=('JetBrains Mono', 12, 'bold'))
        wp_frame.pack(fill='x', padx=10, pady=10)
        
        wp_buttons = [
            ("🖼️ Next Wallpaper", self.next_wallpaper),
            ("🎲 Random", self.random_wallpaper),
            ("📂 Open Directory", self.open_wallpaper_dir)
        ]
        
        for text, command in wp_buttons:
            tk.Button(wp_frame,
                     text=text,
                     command=command,
                     bg=self.colors['blue'],
                     fg=self.colors['bg'],
                     font=('JetBrains Mono', 10),
                     padx=15,
                     pady=5).pack(side='left', padx=5, pady=10)
    
    def create_audio_tab(self):
        """Audio control tab"""
        audio_frame = ttk.Frame(self.notebook)
        self.notebook.add(audio_frame, text=" Audio ")
        
        # Volume Control
        volume_frame = tk.LabelFrame(audio_frame,
                                    text=" Volume Control ",
                                    bg=self.colors['bg'],
                                    fg=self.colors['mauve'],
                                    font=('JetBrains Mono', 12, 'bold'))
        volume_frame.pack(fill='x', padx=10, pady=10)
        
        self.volume_scale = tk.Scale(volume_frame,
                                    from_=0,
                                    to=150,
                                    orient='horizontal',
                                    bg=self.colors['bg'],
                                    fg=self.colors['text'],
                                    highlightthickness=0,
                                    command=self.set_volume)
        self.volume_scale.set(50)
        self.volume_scale.pack(fill='x', padx=10, pady=10)
        
        # Audio Actions
        actions_frame = tk.Frame(audio_frame, bg=self.colors['bg'])
        actions_frame.pack(fill='x', padx=10, pady=10)
        
        audio_buttons = [
            ("🔇 Mute", self.toggle_mute, self.colors['red']),
            ("🎤 Mic Mute", self.toggle_mic, self.colors['yellow']),
            ("🔊 Test Audio", self.test_audio, self.colors['green'])
        ]
        
        for text, command, color in audio_buttons:
            tk.Button(actions_frame,
                     text=text,
                     command=command,
                     bg=color,
                     fg=self.colors['bg'],
                     font=('JetBrains Mono', 10, 'bold'),
                     padx=15,
                     pady=8).pack(side='left', padx=5)
    
    def create_network_tab(self):
        """Network management tab"""
        network_frame = ttk.Frame(self.notebook)
        self.notebook.add(network_frame, text=" Network ")
        
        # Network Status
        status_frame = tk.LabelFrame(network_frame,
                                    text=" Network Status ",
                                    bg=self.colors['bg'],
                                    fg=self.colors['mauve'],
                                    font=('JetBrains Mono', 12, 'bold'))
        status_frame.pack(fill='x', padx=10, pady=10)
        
        self.net_status_label = tk.Label(status_frame,
                                        text="Loading network status...",
                                        bg=self.colors['bg'],
                                        fg=self.colors['text'],
                                        font=('JetBrains Mono', 10))
        self.net_status_label.pack(padx=10, pady=10)
        
        # Network Actions
        actions_frame = tk.LabelFrame(network_frame,
                                     text=" Network Actions ",
                                     bg=self.colors['bg'],
                                     fg=self.colors['mauve'],
                                     font=('JetBrains Mono', 12, 'bold'))
        actions_frame.pack(fill='x', padx=10, pady=10)
        
        net_buttons = [
            ("📡 WiFi Toggle", self.toggle_wifi),
            ("🔒 VPN Connect", self.toggle_vpn),
            ("🌐 Check Internet", self.check_internet),
            ("🔄 Refresh", self.refresh_network)
        ]
        
        for i, (text, command) in enumerate(net_buttons):
            tk.Button(actions_frame,
                     text=text,
                     command=command,
                     bg=self.colors['blue'],
                     fg=self.colors['bg'],
                     font=('JetBrains Mono', 10),
                     padx=15,
                     pady=8).grid(row=i//2, column=i%2, padx=5, pady=5, sticky='ew')
    
    def create_status_bar(self):
        """Create status bar at bottom"""
        self.status_bar = tk.Label(self.root,
                                  text="Ready",
                                  bg=self.colors['bg_light'],
                                  fg=self.colors['text'],
                                  font=('JetBrains Mono', 9),
                                  anchor='w',
                                  padx=10)
        self.status_bar.pack(fill='x', side='bottom', padx=10, pady=5)
    
    # ===== ACTION METHODS =====
    
    def run_command(self, cmd, shell=True):
        """Run a shell command and return output"""
        try:
            result = subprocess.run(cmd,
                                  shell=shell,
                                  capture_output=True,
                                  text=True,
                                  timeout=30)
            return result.returncode == 0, result.stdout, result.stderr
        except Exception as e:
            return False, "", str(e)
    
    def refresh_status(self):
        """Refresh all system status information"""
        threading.Thread(target=self._refresh_status_thread, daemon=True).start()
    
    def _refresh_status_thread(self):
        """Background thread for status refresh"""
        try:
            # Get system info
            success, os_info, _ = self.run_command('cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d \'"\'')
            if success:
                self.sys_labels['os_info'].config(text=os_info.strip())
            
            success, kernel, _ = self.run_command("uname -r")
            if success:
                self.sys_labels['kernel_info'].config(text=kernel.strip())
            
            success, uptime, _ = self.run_command("uptime -p")
            if success:
                self.sys_labels['uptime_info'].config(text=uptime.strip())
            
            success, memory, _ = self.run_command("free -h | grep Mem | awk '{print $3 \" / \" $2}'")
            if success:
                self.sys_labels['memory_info'].config(text=memory.strip())
            
            success, disk, _ = self.run_command("df -h / | tail -1 | awk '{print $3 \" / \" $2 \" (\" $5 \")\"}'")
            if success:
                self.sys_labels['disk_info'].config(text=disk.strip())
            
            success, cpu, _ = self.run_command("grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | tr -s ' ' | head -c 30")
            if success:
                self.sys_labels['cpu_info'].config(text=cpu.strip() + "...")
            
            self.status_bar.config(text=f"Last updated: {datetime.now().strftime('%H:%M:%S')}")
            
        except Exception as e:
            self.status_bar.config(text=f"Error refreshing: {e}")
    
    def quick_setup(self):
        """Run quick setup"""
        if messagebox.askyesno("Quick Setup", "Run S1Bs1stem ORCHESTRA?"):
            threading.Thread(target=self._run_orchestra_thread, daemon=True).start()
    
    def _run_orchestra_thread(self):
        """Run ORCHESTRA in background"""
        self.status_bar.config(text="Running ORCHESTRA...")
        success, stdout, stderr = self.run_command("bash ~/.local/s1barch/install/ORCHESTRA.sh --dry-run")
        if success:
            messagebox.showinfo("Success", "ORCHESTRA dry-run completed successfully!")
        else:
            messagebox.showerror("Error", f"ORCHESTRA failed:\n{stderr}")
        self.status_bar.config(text="Ready")
    
    def clean_system(self):
        """Run system cleanup"""
        if messagebox.askyesno("Clean System", "Clean pacman cache, temp files, and logs?"):
            threading.Thread(target=self._clean_system_thread, daemon=True).start()
    
    def _clean_system_thread(self):
        """System cleanup in background"""
        self.status_bar.config(text="Cleaning system...")
        self.run_command("bash ~/.local/s1barch/scripts/system/cleanup.sh")
        self.status_bar.config(text="System cleaned")
        messagebox.showinfo("Success", "System cleanup completed!")
    
    def create_snapshot(self):
        """Create system snapshot"""
        name = f"gui_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        threading.Thread(target=self._create_snapshot_thread, args=(name,), daemon=True).start()
    
    def _create_snapshot_thread(self, name):
        """Create snapshot in background"""
        self.status_bar.config(text=f"Creating snapshot: {name}...")
        success, stdout, stderr = self.run_command(f"bash ~/.local/s1barch/scripts/rollback/snapshot_create.sh {name}")
        if success:
            messagebox.showinfo("Success", f"Snapshot '{name}' created!")
        else:
            messagebox.showerror("Error", f"Failed to create snapshot:\n{stderr}")
        self.status_bar.config(text="Ready")
    
    def launch_workflow(self, workflow):
        """Launch a workflow"""
        threading.Thread(target=self._launch_workflow_thread, args=(workflow,), daemon=True).start()
    
    def _launch_workflow_thread(self, workflow):
        """Launch workflow in background"""
        self.status_bar.config(text=f"Launching workflow: {workflow}...")
        self.run_command(f"bash ~/.local/s1barch/scripts/workflow/{workflow}.sh")
        self.status_bar.config(text=f"Workflow {workflow} launched")
    
    def set_brightness(self, value):
        """Set screen brightness"""
        value = int(float(value))
        threading.Thread(target=self._set_brightness_thread, args=(value,), daemon=True).start()
    
    def _set_brightness_thread(self, value):
        """Set brightness in background"""
        self.run_command(f"brightnessctl set {value}%")
    
    def set_volume(self, value):
        """Set audio volume"""
        value = int(float(value))
        threading.Thread(target=self._set_volume_thread, args=(value,), daemon=True).start()
    
    def _set_volume_thread(self, value):
        """Set volume in background"""
        self.run_command(f"pactl set-sink-volume @DEFAULT_SINK@ {value}%")
    
    def next_wallpaper(self):
        """Cycle to next wallpaper"""
        self.run_command("bash ~/.local/s1barch/scripts/display/wallpaper_cycle.sh cycle")
        self.status_bar.config(text="Wallpaper changed")
    
    def random_wallpaper(self):
        """Set random wallpaper"""
        self.run_command("bash ~/.local/s1barch/scripts/display/wallpaper_cycle.sh random")
        self.status_bar.config(text="Random wallpaper set")
    
    def toggle_mute(self):
        """Toggle audio mute"""
        self.run_command("pactl set-sink-mute @DEFAULT_SINK@ toggle")
        self.status_bar.config(text="Mute toggled")
    
    def toggle_wifi(self):
        """Toggle WiFi"""
        self.run_command("bash ~/.local/s1barch/scripts/networking/wifi_toggle.sh --toggle")
        self.refresh_network()
    
    def toggle_vpn(self):
        """Toggle VPN"""
        self.run_command("bash ~/.local/s1barch/scripts/networking/vpn_connect.sh --toggle")
    
    def check_internet(self):
        """Check internet connectivity"""
        success, _, _ = self.run_command("ping -c 1 google.com")
        if success:
            messagebox.showinfo("Internet", "✅ Internet connection is working!")
        else:
            messagebox.showerror("Internet", "❌ No internet connection!")
    
    def refresh_network(self):
        """Refresh network status"""
        success, status, _ = self.run_command("bash ~/.local/s1barch/scripts/networking/network_status.sh 2>&1 | head -20")
        if success:
            self.net_status_label.config(text=status[:200] + "...")
    
    # Other methods
    def run_orchestra(self):
        """Menu: Run ORCHESTRA"""
        self.quick_setup()
    
    def show_system_info(self):
        """Menu: Show system info"""
        self.run_command("bash ~/.local/s1barch/scripts/system/system_info.sh")
    
    def clear_logs(self):
        """Menu: Clear logs"""
        if messagebox.askyesno("Clear Logs", "Clear all S1Bs1stem logs?"):
            self.run_command("bash ~/.local/s1barch/scripts/system/log_clean.sh")
            messagebox.showinfo("Success", "Logs cleared!")
    
    def restore_snapshot(self):
        """Menu: Restore snapshot"""
        messagebox.showinfo("Info", "Use terminal to restore: s1b-restore-snapshot")
    
    def view_logs(self):
        """Menu: View logs"""
        log_window = tk.Toplevel(self.root)
        log_window.title("S1Bs1stem Logs")
        log_window.geometry("800x600")
        log_window.configure(bg=self.colors['bg'])
        
        text = scrolledtext.ScrolledText(log_window,
                                        bg=self.colors['bg'],
                                        fg=self.colors['text'],
                                        font=('JetBrains Mono', 9))
        text.pack(fill='both', expand=True, padx=10, pady=10)
        
        success, logs, _ = self.run_command("tail -n 100 ~/.s1b_logs/s1b_system.log 2>/dev/null || echo 'No logs found'")
        text.insert('1.0', logs)
        text.config(state='disabled')
    
    def open_wallpaper_dir(self):
        """Open wallpaper directory"""
        self.run_command("xdg-open ~/Pictures/wallpapers")
    
    def toggle_mic(self):
        """Toggle microphone mute"""
        self.run_command("pactl set-source-mute @DEFAULT_SOURCE@ toggle")
        self.status_bar.config(text="Microphone toggled")
    
    def test_audio(self):
        """Test audio"""
        self.run_command("speaker-test -t sine -f 1000 -l 1 &")
        self.status_bar.config(text="Audio test running")
    
    def open_docs(self):
        """Open documentation"""
        self.run_command("xdg-open ~/.local/s1barch/README.md")
    
    def show_about(self):
        """Show about dialog"""
        messagebox.showinfo("About",
                           "S1Bs1stem Control Center v1.0\n\n"
                           "A comprehensive system management GUI\n"
                           "for S1Bs1stem automation framework.\n\n"
                           "© 2025 S1B System\n"
                           "License: MIT")

def main():
    """Main entry point"""
    root = tk.Tk()
    app = S1BControlCenter(root)
    root.mainloop()

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
ms - Modern ls command replacement
A feature-rich directory listing utility with enhanced formatting and filtering
"""

import os
import sys
import argparse
import stat
import time
import pwd
import grp
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from datetime import datetime
import humanize
import shutil
import shutil as sh


class MSCommand:
    def __init__(self):
        self.files = []
        self.dirs = []
        self.links = []
        self.special = []
        
    def get_file_info(self, path: Path) -> Dict:
        """Get detailed file information"""
        try:
            stat_info = path.lstat()
            is_link = path.is_symlink()
            file_size = stat_info.st_size if not is_link else os.readlink(str(path))
            
            # Get file type
            if path.is_dir():
                file_type = 'd'
            elif path.is_symlink():
                file_type = 'l'
            elif path.is_block_device():
                file_type = 'b'
            elif path.is_char_device():
                file_type = 'c'
            elif path.is_fifo():
                file_type = 'p'
            elif path.is_socket():
                file_type = 's'
            elif hasattr(stat, 'S_ISDOOR') and stat.S_ISDOOR(stat_info.st_mode):
                file_type = 'D'  # Doors (Solaris-specific)
            else:
                file_type = '-'
            
            # Get permissions
            permissions = stat.filemode(stat_info.st_mode)
            mode = oct(stat_info.st_mode)[-3:]
            
            # Get owner and group
            try:
                owner = pwd.getpwuid(stat_info.st_uid).pw_name
            except KeyError:
                owner = str(stat_info.st_uid)
            
            try:
                group = grp.getgrgid(stat_info.st_gid).gr_name
            except KeyError:
                group = str(stat_info.st_gid)
            
            # Get modification time
            mod_time = datetime.fromtimestamp(stat_info.st_mtime)
            
            # Get human readable size
            if path.is_dir():
                size_str = self.get_directory_size(path)
            else:
                size_str = humanize.naturalsize(file_size)
            
            return {
                'name': path.name,
                'path': path,
                'type': file_type,
                'permissions': permissions,
                'mode': mode,
                'owner': owner,
                'group': group,
                'size': file_size,
                'size_str': size_str,
                'mtime': mod_time,
                'is_link': is_link,
                'is_dir': path.is_dir()
            }
        except (OSError, IOError):
            return None
    
    def get_directory_size(self, path: Path) -> str:
        """Get the size of a directory in human readable format"""
        try:
            total_size = 0
            for dirpath, dirnames, filenames in os.walk(path):
                for filename in filenames:
                    filepath = os.path.join(dirpath, filename)
                    try:
                        total_size += os.path.getsize(filepath)
                    except (OSError, IOError):
                        pass
            return humanize.naturalsize(total_size)
        except (OSError, IOError):
            return '0 B'
    
    def categorize_files(self, paths: List[Path]) -> None:
        """Categorize files by type"""
        self.files = []
        self.dirs = []
        self.links = []
        self.special = []
        
        for path in paths:
            info = self.get_file_info(path)
            if info:
                if info['is_dir']:
                    self.dirs.append(info)
                elif info['is_link']:
                    self.links.append(info)
                elif info['type'] in ['b', 'c', 'p', 's', 'D']:
                    self.special.append(info)
                else:
                    self.files.append(info)
    
    def sort_files(self, sort_by: str, reverse: bool = False):
        """Sort files by specified criteria"""
        def get_sort_key(item):
            if sort_by == 'name':
                return item['name'].lower()
            elif sort_by == 'size':
                # For directories, use the directory size, for others use file size
                if item['is_dir']:
                    return self.get_directory_size_numeric(item['path'])
                else:
                    return item['size']
            elif sort_by == 'time':
                return item['mtime']
            elif sort_by == 'type':
                return item['type']
            return item['name'].lower()
        
        self.dirs.sort(key=get_sort_key, reverse=reverse)
        self.files.sort(key=get_sort_key, reverse=reverse)
        self.links.sort(key=get_sort_key, reverse=reverse)
        self.special.sort(key=get_sort_key, reverse=reverse)
    
    def get_directory_size_numeric(self, path: Path) -> int:
        """Get directory size as numeric value for sorting"""
        try:
            total_size = 0
            for dirpath, dirnames, filenames in os.walk(path):
                for filename in filenames:
                    filepath = os.path.join(dirpath, filename)
                    try:
                        total_size += os.path.getsize(filepath)
                    except (OSError, IOError):
                        pass
            return total_size
        except (OSError, IOError):
            return 0
    
    def filter_files(self, pattern: Optional[str], hidden: bool = False):
        """Filter files by pattern and hidden status"""
        def matches_pattern(name, pattern):
            if not pattern:
                return True
            import fnmatch
            return fnmatch.fnmatch(name, pattern)
        
        def should_show(name):
            if not hidden and name.startswith('.'):
                return False
            return True
        
        self.dirs = [f for f in self.dirs if should_show(f['name']) and matches_pattern(f['name'], pattern)]
        self.files = [f for f in self.files if should_show(f['name']) and matches_pattern(f['name'], pattern)]
        self.links = [f for f in self.links if should_show(f['name']) and matches_pattern(f['name'], pattern)]
        self.special = [f for f in self.special if should_show(f['name']) and matches_pattern(f['name'], pattern)]
    
    def format_output(self, long_format: bool, human_readable: bool, time_format: str, mode: str = 'list'):
        """Format and display the output"""
        
        all_items = self.dirs + self.files + self.links + self.special
        
        if mode == 'tree':
            return self.format_tree_view(False)
        elif mode == 'tree_metadata':
            return self.format_tree_view(True)
        elif mode == 'table':
            return self.format_table_view()
        elif mode == 'two_column':
            return self.format_two_column_view()
        elif mode == 'zebra':
            return self.format_zebra_view(False)
        elif mode == 'zebra_metadata':
            return self.format_zebra_view(True)
        elif mode == 'list':
            return self.format_list_view(long_format, human_readable, time_format)
        else:
            return self.format_list_view(long_format, human_readable, time_format)
    
    def format_tree_view(self, show_metadata: bool) -> List[str]:
        """Format output in tree view"""
        output_lines = []
        all_items = self.dirs + self.files + self.links + self.special
        
        for item in all_items:
            if item['is_dir']:
                # Tree view for directories
                prefix = "├── "
                name = f"\033[34m{item['name']}/\033[0m"
                if show_metadata:
                    mtime_str = item['mtime'].strftime('%Y-%m-%d %H:%M')
                    metadata = f" {item['size_str']} {mtime_str}"
                    line = f"{prefix}{name}{metadata}"
                else:
                    line = f"{prefix}{name}"
                output_lines.append(line)
            else:
                # Tree view for files
                prefix = "├── "
                if item['is_link']:
                    link_target = os.readlink(str(item['path']))
                    name = f"\033[36m{item['name']} -> {link_target}\033[0m"
                elif item['size'] > 1024 * 1024:
                    name = f"\033[31m{item['name']}\033[0m"
                elif item['size'] > 1024:
                    name = f"\033[33m{item['name']}\033[0m"
                else:
                    name = item['name']
                
                if show_metadata:
                    mtime_str = item['mtime'].strftime('%Y-%m-%d %H:%M')
                    metadata = f" {item['size_str']} {mtime_str}"
                    line = f"{prefix}{name}{metadata}"
                else:
                    line = f"{prefix}{name}"
                output_lines.append(line)
        
        return output_lines
    
    def format_table_view(self) -> List[str]:
        """Format output in table view with name and size"""
        output_lines = []
        all_items = self.dirs + self.files + self.links + self.special
        
        # Calculate column widths
        max_name_len = max([len(item['name']) for item in all_items] + [10])
        max_size_len = max([len(item['size_str']) for item in all_items] + [10])
        
        # Header
        header = f"{'Name':<{max_name_len}} {'Size':>{max_size_len}}"
        output_lines.append(header)
        output_lines.append('-' * (max_name_len + max_size_len + 1))
        
        # Data rows
        for item in all_items:
            name = item['name']
            if item['is_dir']:
                name = f"\033[34m{name}/\033[0m"
            elif item['is_link']:
                link_target = os.readlink(str(item['path']))
                name = f"\033[36m{name} -> {link_target}\033[0m"
            elif item['size'] > 1024 * 1024:
                name = f"\033[31m{name}\033[0m"
            elif item['size'] > 1024:
                name = f"\033[33m{name}\033[0m"
            
            line = f"{name:<{max_name_len}} {item['size_str']:>{max_size_len}}"
            output_lines.append(line)
        
        return output_lines
    
    def format_two_column_view(self) -> List[str]:
        """Format output in 2-column view"""
        output_lines = []
        all_items = self.dirs + self.files + self.links + self.special
        
        # Calculate terminal width and column widths
        try:
            terminal_width = shutil.get_terminal_size().columns
        except:
            terminal_width = 80
        
        col_width = (terminal_width - 3) // 2
        
        # Format items for 2 columns
        formatted_items = []
        for item in all_items:
            name = item['name']
            if item['is_dir']:
                name = f"\033[34m{name}/\033[0m"
            elif item['is_link']:
                link_target = os.readlink(str(item['path']))
                name = f"\033[36m{name}\033[0m"
            elif item['size'] > 1024 * 1024:
                name = f"\033[31m{name}\033[0m"
            elif item['size'] > 1024:
                name = f"\033[33m{name}\033[0m"
            
            formatted_name = name[:col_width-1] + '…' if len(name) > col_width else name
            formatted_items.append(formatted_name)
        
        # Display in 2 columns
        for i in range(0, len(formatted_items), 2):
            if i + 1 < len(formatted_items):
                line = f"{formatted_items[i]:<{col_width}}  {formatted_items[i+1]:<{col_width}}"
            else:
                line = f"{formatted_items[i]:<{col_width}}"
            output_lines.append(line)
        
        return output_lines
    
    def format_zebra_view(self, show_metadata: bool) -> List[str]:
        """Format output in zebra striping view"""
        output_lines = []
        all_items = self.dirs + self.files + self.links + self.special
        
        for i, item in enumerate(all_items):
            # Zebra striping
            if i % 2 == 0:
                bg_color = '\033[48;5;235m'  # Dark gray background
                reset = '\033[0m'
            else:
                bg_color = ''
                reset = ''
            
            name = item['name']
            if item['is_dir']:
                name = f"\033[34m{name}/\033[0m"
            elif item['is_link']:
                link_target = os.readlink(str(item['path']))
                name = f"\033[36m{name} -> {link_target}\033[0m"
            elif item['size'] > 1024 * 1024:
                name = f"\033[31m{name}\033[0m"
            elif item['size'] > 1024:
                name = f"\033[33m{name}\033[0m"
            
            if show_metadata:
                mtime_str = item['mtime'].strftime('%Y-%m-%d %H:%M')
                metadata = f"  {item['size_str']} {mtime_str}"
                line = f"{bg_color}{name}{metadata}{reset}"
            else:
                line = f"{bg_color}{name}{reset}"
            
            output_lines.append(line)
        
        return output_lines
    
    def format_list_view(self, long_format: bool, human_readable: bool, time_format: str) -> List[str]:
        """Format output in traditional list view"""
        output_lines = []
        
        # Calculate column widths for long format
        if long_format:
            max_name_len = max([len(f['name']) for f in self.dirs + self.files + self.links + self.special] + [4])
            max_owner_len = max([len(f['owner']) for f in self.dirs + self.files + self.links + self.special] + [4])
            max_group_len = max([len(f['group']) for f in self.dirs + self.files + self.links + self.special] + [4])
            max_size_len = max([len(f['size_str']) for f in self.dirs + self.files + self.links + self.special] + [4])
        
        # Format directories
        for item in self.dirs:
            if long_format:
                mtime_str = item['mtime'].strftime(time_format)
                line = f"{item['permissions']} {item['owner']:<{max_owner_len}} {item['group']:<{max_group_len}} {item['size_str']:>{max_size_len}} {mtime_str} \033[34m{item['name']}/\033[0m"
            else:
                line = f"\033[34m{item['name']}/\033[0m"
            output_lines.append(line)
        
        # Format files
        for item in self.files:
            if long_format:
                mtime_str = item['mtime'].strftime(time_format)
                if item['size'] > 1024 * 1024:  # Large files in red
                    color = '\033[31m'
                elif item['size'] > 1024:  # Medium files in yellow
                    color = '\033[33m'
                else:
                    color = '\033[0m'
                line = f"{item['permissions']} {item['owner']:<{max_owner_len}} {item['group']:<{max_group_len}} {item['size_str']:>{max_size_len}} {mtime_str} {color}{item['name']}\033[0m"
            else:
                line = item['name']
            output_lines.append(line)
        
        # Format links
        for item in self.links:
            if long_format:
                mtime_str = item['mtime'].strftime(time_format)
                link_target = os.readlink(str(item['path']))
                line = f"{item['permissions']} {item['owner']:<{max_owner_len}} {item['group']:<{max_group_len}} {item['size_str']:>{max_size_len}} {mtime_str} \033[36m{item['name']} -> {link_target}\033[0m"
            else:
                link_target = os.readlink(str(item['path']))
                line = f"\033[36m{item['name']} -> {link_target}\033[0m"
            output_lines.append(line)
        
        # Format special files
        for item in self.special:
            if long_format:
                mtime_str = item['mtime'].strftime(time_format)
                line = f"{item['permissions']} {item['owner']:<{max_owner_len}} {item['group']:<{max_group_len}} {item['size_str']:>{max_size_len}} {mtime_str} \033[35m{item['name']}\033[0m"
            else:
                line = f"\033[35m{item['name']}\033[0m"
            output_lines.append(line)
        
        return output_lines
    
    def run(self, args):
        """Main execution function"""
        # Get paths to list
        paths = args.paths if args.paths else [Path('.')]
        
        all_items = []
        for path in paths:
            path = Path(path)
            if not path.exists():
                print(f"ms: cannot access '{path}': No such file or directory", file=sys.stderr)
                continue
            
            if path.is_file():
                all_items.append(path)
            else:
                try:
                    for item in path.iterdir():
                        all_items.append(item)
                except PermissionError:
                    print(f"ms: cannot open directory '{path}': Permission denied", file=sys.stderr)
        
        # Categorize and filter
        self.categorize_files(all_items)
        self.filter_files(args.pattern, args.all)
        self.sort_files(args.sort, args.reverse)
        
        # Determine output mode
        mode = 'list'
        if args.tree:
            mode = 'tree'
        elif args.tree_metadata:
            mode = 'tree_metadata'
        elif args.table:
            mode = 'table'
        elif args.two_column:
            mode = 'two_column'
        elif args.zebra:
            mode = 'zebra'
        elif args.zebra_metadata:
            mode = 'zebra_metadata'
        
        # Generate output
        lines = self.format_output(args.long, args.human, args.time_format, mode)
        
        # Print results
        if lines:
            print('\n'.join(lines))
            
            # Print summary if requested
            if args.summary:
                total_items = len(self.dirs) + len(self.files) + len(self.links) + len(self.special)
                total_dirs = len(self.dirs)
                total_files = len(self.files)
                total_links = len(self.links)
                total_special = len(self.special)
                
                print(f"\nTotal: {total_items} items", end="")
                if total_dirs > 0:
                    print(f", {total_dirs} directories", end="")
                if total_files > 0:
                    print(f", {total_files} files", end="")
                if total_links > 0:
                    print(f", {total_links} links", end="")
                if total_special > 0:
                    print(f", {total_special} special files", end="")
                print()


def main():
    parser = argparse.ArgumentParser(
        description="Modern ls command replacement with enhanced formatting and features",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  ms                    # List current directory
  ms -la /etc          # List /etc with all details
  ms -s --pattern="*.py"  # Show summary of Python files
  ms -Sr --long        # Sort by size, reverse order, long format
  ms -t --time-format="%Y-%m-%d %H:%M"  # Custom time format

Color coding:
  Blue: directories
  Cyan: symbolic links  
  Magenta: special files (devices, pipes, sockets)
  Red: large files (>1MB)
  Yellow: medium files (1KB-1MB)
        """
    )
    
    parser.add_argument('paths', nargs='*', help='Paths to list (default: current directory)')
    parser.add_argument('-l', '--long', action='store_true', help='Long format listing')
    parser.add_argument('-a', '--all', action='store_true', help='Show all files including hidden')
    parser.add_argument('-A', '--almost-all', action='store_true', help='Show all except . and ..')
    parser.add_argument('-r', '--reverse', action='store_true', help='Reverse sort order')
    parser.add_argument('-t', '--sort', choices=['name', 'size', 'time', 'type'], 
                       default='name', help='Sort by (default: name)')
    parser.add_argument('-s', '--summary', action='store_true', help='Show summary at the end')
    parser.add_argument('-H', '--human', action='store_true', help='Human readable sizes')

    parser.add_argument('-k', '--tree', action='store_true', help='Tree view listing')
    parser.add_argument('-K', '--tree-metadata', action='store_true', help='Tree view with metadata')
    parser.add_argument('-n', '--table', action='store_true', help='Table view with name and size')
    parser.add_argument('-N', '--two-column', action='store_true', help='Two column view')
    parser.add_argument('-z', '--zebra', action='store_true', help='Zebra striping list view')
    parser.add_argument('-Z', '--zebra-metadata', action='store_true', help='Zebra striping with metadata')
    parser.add_argument('--pattern', help='Filter by pattern (wildcards supported)')
    parser.add_argument('--time-format', default='%b %d %H:%M', 
                       help='Time format (default: %%b %%d %%H:%%M)')
    parser.add_argument('--version', action='version', version='ms 1.1.1')
    

    
    args = parser.parse_args()
    
    ms = MSCommand()
    ms.run(args)


if __name__ == '__main__':
    main()
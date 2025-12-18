#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <algorithm>
#include <fstream>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <grp.h>
#include <pwd.h>
#include <ctime>
#include <cstring>

namespace fs = std::filesystem;

class MSCommand {
private:
    bool show_tree = false;
    bool show_tree_metadata = false;
    bool show_table_name_size = false;
    bool show_two_column = false;
    bool show_zebra = false;
    bool show_zebra_metadata = false;
    bool human_readable = false;
    bool show_table_horizontal = false;
    bool show_table_with_metadata = false;
    bool show_help = false;
    bool show_details = false;
    bool show_long_format = false;
    bool recursive = false;
    bool all_files = false;
    
    std::string sort_by = "name"; // name, size, time, type
    bool sort_descending = false;
    
    std::vector<std::string> paths;
    
    struct FileInfo {
        std::string name;
        std::string path;
        bool is_directory;
        uint64_t size;
        std::string permissions;
        std::string owner;
        std::string group;
        std::string modified_time;
        std::string type;
    };
    
    void print_help() {
        std::cout << "ms - Modern ls replacement\n\n";
        std::cout << "Usage: ms [OPTIONS] [PATH...]\n\n";
        std::cout << "Options:\n";
        std::cout << "  -h, --help              Show this help message\n";
        std::cout << "  -l                      Long format listing\n";
        std::cout << "  -a, --all               Show hidden files\n";
        std::cout << "  -R, --recursive         Recursively list directories\n";
        std::cout << "  -k                      Tree view\n";
        std::cout << "  -K                      Tree view with metadata\n";
        std::cout << "  -n                      Table mode with name and size\n";
        std::cout << "  -N                      2 column row mode\n";
        std::cout << "  -z                      Zebra list view\n";
        std::cout << "  -Z                      Zebra list view with metadata\n";
        std::cout << "  -H                      Human readable sizes\n";
        std::cout << "  -t                      Table 2xN horizontal mode\n";
        std::cout << "  -T                      Table 2xN with metadata\n";
        std::cout << "  -d                      Show details\n";
        std::cout << "  --sort=SORT_BY          Sort by (name, size, time, type)\n";
        std::cout << "  --reverse               Reverse sort order\n";
        std::cout << "\nExamples:\n";
        std::cout << "  ms                      List current directory\n";
        std::cout << "  ms -l /home             Long format listing of /home\n";
        std::cout << "  ms -k /usr/bin          Tree view of /usr/bin\n";
        std::cout << "  ms -n -H .              Table with human readable sizes\n";
        std::cout << "  ms -z -R                Zebra view recursively\n";
    }
    
    std::string get_file_type(const struct stat& st) {
        if (S_ISDIR(st.st_mode)) return "d";
        if (S_ISREG(st.st_mode)) return "-";
        if (S_ISLNK(st.st_mode)) return "l";
        if (S_ISCHR(st.st_mode)) return "c";
        if (S_ISBLK(st.st_mode)) return "b";
        if (S_ISFIFO(st.st_mode)) return "p";
        if (S_ISSOCK(st.st_mode)) return "s";
        return "?";
    }
    
    std::string get_permissions(const struct stat& st) {
        std::string perms = "----------";
        perms[0] = get_file_type(st)[0];
        
        if (st.st_mode & S_IRUSR) perms[1] = 'r';
        if (st.st_mode & S_IWUSR) perms[2] = 'w';
        if (st.st_mode & S_IXUSR) perms[3] = 'x';
        if (st.st_mode & S_IRGRP) perms[4] = 'r';
        if (st.st_mode & S_IWGRP) perms[5] = 'w';
        if (st.st_mode & S_IXGRP) perms[6] = 'x';
        if (st.st_mode & S_IROTH) perms[7] = 'r';
        if (st.st_mode & S_IWOTH) perms[8] = 'w';
        if (st.st_mode & S_IXOTH) perms[9] = 'x';
        
        return perms;
    }
    
    std::string format_size(uint64_t size, bool human_readable) {
        if (!human_readable) {
            return std::to_string(size);
        }
        
        const char* units[] = {"B", "K", "M", "G", "T", "P"};
        int unit_index = 0;
        double human_size = size;
        
        while (human_size >= 1024 && unit_index < 5) {
            human_size /= 1024;
            unit_index++;
        }
        
        std::ostringstream oss;
        oss << std::fixed << std::setprecision(1) << human_size << units[unit_index];
        return oss.str();
    }
    
    std::string format_time(const struct stat& st) {
        auto time_t = st.st_mtime;
        auto tm = std::localtime(&time_t);
        std::ostringstream oss;
        oss << std::put_time(tm, "%Y-%m-%d %H:%M:%S");
        return oss.str();
    }
    
    std::vector<FileInfo> get_file_list(const std::string& path) {
        std::vector<FileInfo> files;
        DIR* dir = opendir(path.c_str());
        
        if (!dir) {
            std::cerr << "Error: Cannot open directory " << path << std::endl;
            return files;
        }
        
        struct dirent* entry;
        while ((entry = readdir(dir)) != nullptr) {
            if (!all_files && entry->d_name[0] == '.') {
                continue;
            }
            
            std::string full_path = path + "/" + entry->d_name;
            struct stat st;
            
            if (stat(full_path.c_str(), &st) == 0) {
                FileInfo file;
                file.name = entry->d_name;
                file.path = full_path;
                file.is_directory = S_ISDIR(st.st_mode);
                file.size = st.st_size;
                file.permissions = get_permissions(st);
                file.type = get_file_type(st);
                
                struct passwd* pwd = getpwuid(st.st_uid);
                struct group* grp = getgrgid(st.st_gid);
                file.owner = pwd ? pwd->pw_name : std::to_string(st.st_uid);
                file.group = grp ? grp->gr_name : std::to_string(st.st_gid);
                file.modified_time = format_time(st);
                
                files.push_back(file);
            }
        }
        
        closedir(dir);
        return files;
    }
    
    void sort_files(std::vector<FileInfo>& files) {
        if (sort_by == "size") {
            std::sort(files.begin(), files.end(), 
                [this](const FileInfo& a, const FileInfo& b) {
                    return sort_descending ? a.size > b.size : a.size < b.size;
                });
        } else if (sort_by == "time") {
            std::sort(files.begin(), files.end(),
                [this](const FileInfo& a, const FileInfo& b) {
                    return sort_descending ? a.modified_time > b.modified_time : a.modified_time < b.modified_time;
                });
        } else if (sort_by == "type") {
            std::sort(files.begin(), files.end(),
                [this](const FileInfo& a, const FileInfo& b) {
                    return sort_descending ? a.type > b.type : a.type < b.type;
                });
        } else { // sort by name
            std::sort(files.begin(), files.end(),
                [this](const FileInfo& a, const FileInfo& b) {
                    return sort_descending ? a.name > b.name : a.name < b.name;
                });
        }
    }
    
    void print_tree(const std::string& path, const std::string& prefix = "", bool with_metadata = false) {
        auto files = get_file_list(path);
        sort_files(files);
        
        for (size_t i = 0; i < files.size(); ++i) {
            bool is_last = (i == files.size() - 1);
            std::string current_prefix = prefix + (is_last ? "└── " : "├── ");
            std::string full_prefix = prefix + (is_last ? "    " : "│   ");
            
            std::cout << current_prefix << files[i].name;
            
            if (with_metadata) {
                std::cout << " [" << files[i].permissions << "]";
                std::cout << " [" << format_size(files[i].size, human_readable) << "]";
                std::cout << " [" << files[i].modified_time << "]";
            }
            std::cout << std::endl;
            
            if (files[i].is_directory) {
                print_tree(files[i].path, full_prefix, with_metadata);
            }
        }
    }
    
    void print_table_name_size(const std::vector<FileInfo>& files) {
        size_t max_name_len = 0;
        size_t max_size_len = 0;
        
        for (const auto& file : files) {
            max_name_len = std::max(max_name_len, file.name.length());
            max_size_len = std::max(max_size_len, format_size(file.size, human_readable).length());
        }
        
        for (const auto& file : files) {
            std::cout << std::setw(max_name_len) << std::left << file.name 
                     << "  " << std::setw(max_size_len) << format_size(file.size, human_readable)
                     << std::endl;
        }
    }
    
    void print_two_column(const std::vector<FileInfo>& files) {
        size_t max_len = 0;
        for (const auto& file : files) {
            max_len = std::max(max_len, file.name.length());
        }
        
        size_t cols = 80 / (max_len + 2);
        if (cols < 1) cols = 1;
        
        for (size_t i = 0; i < files.size(); i += cols) {
            for (size_t j = 0; j < cols && i + j < files.size(); ++j) {
                if (j > 0) std::cout << "  ";
                std::cout << std::setw(max_len) << std::left << files[i + j].name;
            }
            std::cout << std::endl;
        }
    }
    
    void print_zebra(const std::vector<FileInfo>& files, bool with_metadata = false) {
        for (size_t i = 0; i < files.size(); ++i) {
            if (i % 2 == 0) {
                std::cout << "\033[48;5;236m"; // Dark gray background
            } else {
                std::cout << "\033[48;5;235m"; // Even darker gray
            }
            
            std::cout << std::setw(20) << std::left << files[i].name;
            
            if (with_metadata) {
                std::cout << " " << std::setw(10) << files[i].permissions;
                std::cout << " " << std::setw(10) << format_size(files[i].size, human_readable);
                std::cout << " " << std::setw(12) << files[i].modified_time;
            }
            
            std::cout << "\033[0m" << std::endl; // Reset colors
        }
    }
    
    void print_table_horizontal(const std::vector<FileInfo>& files, bool with_metadata = false) {
        size_t max_name_len = 0;
        if (with_metadata) {
            for (const auto& file : files) {
                max_name_len = std::max(max_name_len, file.name.length());
            }
        }
        
        size_t cols = with_metadata ? 2 : 3;
        size_t rows = (files.size() + cols - 1) / cols;
        
        for (size_t row = 0; row < rows; ++row) {
            for (size_t col = 0; col < cols; ++col) {
                size_t index = row + col * rows;
                if (index < files.size()) {
                    std::cout << std::setw(max_name_len) << std::left << files[index].name;
                    if (with_metadata) {
                        std::cout << " [" << format_size(files[index].size, human_readable) << "]";
                        std::cout << " [" << files[index].permissions << "]";
                    }
                    if (col < cols - 1) std::cout << "  ";
                }
            }
            std::cout << std::endl;
        }
    }
    
    void print_long_format(const std::vector<FileInfo>& files) {
        for (const auto& file : files) {
            std::cout << file.permissions << " ";
            std::cout << std::setw(3) << file.owner << " ";
            std::cout << std::setw(8) << file.group << " ";
            std::cout << std::setw(10) << format_size(file.size, human_readable) << " ";
            std::cout << file.modified_time << " ";
            std::cout << file.name << std::endl;
        }
    }
    
    void process_directory(const std::string& path) {
        if (recursive) {
            std::cout << path << ":" << std::endl;
        }
        
        auto files = get_file_list(path);
        sort_files(files);
        
        if (show_tree) {
            print_tree(path, "", false);
        } else if (show_tree_metadata) {
            print_tree(path, "", true);
        } else if (show_table_name_size) {
            print_table_name_size(files);
        } else if (show_two_column) {
            print_two_column(files);
        } else if (show_zebra) {
            print_zebra(files, false);
        } else if (show_zebra_metadata) {
            print_zebra(files, true);
        } else if (show_table_horizontal) {
            print_table_horizontal(files, false);
        } else if (show_table_with_metadata) {
            print_table_horizontal(files, true);
        } else if (show_long_format) {
            print_long_format(files);
        } else {
            // Default: simple list
            for (const auto& file : files) {
                std::cout << file.name << std::endl;
            }
        }
        
        if (recursive) {
            for (const auto& file : files) {
                if (file.is_directory) {
                    std::cout << std::endl;
                    process_directory(file.path);
                }
            }
        }
    }
    
public:
    MSCommand(int argc, char* argv[]) {
        for (int i = 1; i < argc; ++i) {
            std::string arg = argv[i];
            
            if (arg == "-h" || arg == "--help") {
                show_help = true;
            } else if (arg == "-l") {
                show_long_format = true;
            } else if (arg == "-a" || arg == "--all") {
                all_files = true;
            } else if (arg == "-R" || arg == "--recursive") {
                recursive = true;
            } else if (arg == "-k") {
                show_tree = true;
            } else if (arg == "-K") {
                show_tree_metadata = true;
            } else if (arg == "-n") {
                show_table_name_size = true;
            } else if (arg == "-N") {
                show_two_column = true;
            } else if (arg == "-z") {
                show_zebra = true;
            } else if (arg == "-Z") {
                show_zebra_metadata = true;
            } else if (arg == "-H") {
                human_readable = true;
            } else if (arg == "-t") {
                show_table_horizontal = true;
            } else if (arg == "-T") {
                show_table_with_metadata = true;
            } else if (arg == "-d") {
                show_details = true;
            } else if (arg.substr(0, 7) == "--sort=") {
                sort_by = arg.substr(7);
            } else if (arg == "--reverse") {
                sort_descending = true;
            } else if (arg[0] == '-') {
                // Handle combined flags
                for (size_t j = 1; j < arg.length(); ++j) {
                    switch (arg[j]) {
                        case 'l': show_long_format = true; break;
                        case 'a': all_files = true; break;
                        case 'R': recursive = true; break;
                        case 'k': show_tree = true; break;
                        case 'K': show_tree_metadata = true; break;
                        case 'n': show_table_name_size = true; break;
                        case 'N': show_two_column = true; break;
                        case 'z': show_zebra = true; break;
                        case 'Z': show_zebra_metadata = true; break;
                        case 'H': human_readable = true; break;
                        case 't': show_table_horizontal = true; break;
                        case 'T': show_table_with_metadata = true; break;
                        case 'd': show_details = true; break;
                        default: break;
                    }
                }
            } else {
                paths.push_back(arg);
            }
        }
        
        if (paths.empty()) {
            paths.push_back(".");
        }
    }
    
    void execute() {
        if (show_help) {
            print_help();
            return;
        }
        
        for (size_t i = 0; i < paths.size(); ++i) {
            if (paths.size() > 1) {
                std::cout << paths[i] << ":" << std::endl;
            }
            process_directory(paths[i]);
            if (i < paths.size() - 1) {
                std::cout << std::endl;
            }
        }
    }
};

int main(int argc, char* argv[]) {
    try {
        MSCommand ms(argc, argv);
        ms.execute();
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
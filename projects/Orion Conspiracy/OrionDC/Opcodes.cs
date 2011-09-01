﻿
namespace OrionDC
{
    public class Opcodes
    {
        public struct opcode
        {
            public byte op;
            public string name;
            public int prms;
            public string pdescr;
            public opcode(byte b,string n,int p,string pd)
            {
                op=b;
                name=n;
                prms=p;
                pdescr=pd;
            }
        }
        public const int OPCODE_SIZE = 0xFE;
        public static opcode[] opcodes = new opcode[OPCODE_SIZE]
        {
            new opcode(0x00,"nop",0,""),
            new opcode(0x01,"return",0,""),
            new opcode(0x02,"if_eq",2,""),
            new opcode(0x03,"if_neq",2,""),
            new opcode(0x04,"if_less",2,""),
            new opcode(0x05,"if_greater",2,""),
            new opcode(0x06,"opcode_x06",2,""),
            new opcode(0x07,"opcode_x07",2,""),
            new opcode(0x08,"opcode_x08",2,""),
            new opcode(0x09,"opcode_x09",2,""),
            new opcode(0x0a,"opcode_x0a",1,""),
            new opcode(0x0b,"opcode_x0b",1,""),
            new opcode(0x0c,"opcode_x0c",0,""),
            new opcode(0x0d,"opcode_x0d",0,""),
            new opcode(0x0e,"opcode_x0e",1,""),
            new opcode(0x0f,"check_room",1,""),
            new opcode(0x10,"opcode_x10",1,""),
            new opcode(0x11,"opcode_x11",0,""),
            new opcode(0x12,"if_sound",1,""),
            new opcode(0x13,"if_btn_up",0,""),
            new opcode(0x14,"opcode_x14",0,""),
            new opcode(0x15,"opcode_x15",2,""),
            new opcode(0x16,"opcode_x16",1,""),
            new opcode(0x17,"opcode_x17",1,""),
            new opcode(0x18,"opcode_x18",1,""),
            new opcode(0x19,"opcode_x19",1,""),
            new opcode(0x1a,"opcode_x1a",1,""),
            new opcode(0x1b,"opcode_x1b",1,""),
            new opcode(0x1c,"opcode_x1c",1,""),
            new opcode(0x1d,"opcode_x1d",2,""),
            new opcode(0x1e,"opcode_x1e",1,""),
            new opcode(0x1f,"if_actor_in_room",2,""),
            new opcode(0x20,"opcode_x20",1,""),
            new opcode(0x21,"opcode_x21",1,""),
            new opcode(0x22,"opcode_x22",1,""),
            new opcode(0x23,"opcode_x23",2,""),
            new opcode(0x24,"if_nz",1,""),
            new opcode(0x25,"opcode_x25",1,""),
            new opcode(0x26,"opcode_x26",1,""),
            new opcode(0x27,"opcode_x27",1,""),
            new opcode(0x28,"opcode_x28",2,""),
            new opcode(0x29,"opcode_x29",2,""),
            new opcode(0x2a,"opcode_x2a",3,""),
            new opcode(0x2b,"opcode_x2b",2,""),
            new opcode(0x2c,"else",0,""),
            new opcode(0x2d,"end_if",0,""),
            new opcode(0x2e,"opcode_x2e",0,""),
            new opcode(0x2f,"opcode_x2f",2,""),
            new opcode(0x30,"opcode_x30",2,""),
            new opcode(0x31,"opcode_x31",2,""),
            new opcode(0x32,"opcode_x32",2,""),
            new opcode(0x33,"opcode_x33",2,""),
            new opcode(0x34,"opcode_x34",2,""),
            new opcode(0x35,"jump",1,""),
            new opcode(0x36,"call",1,""),
            new opcode(0x37,"opcode_x37",0,""),
            new opcode(0x38,"opcode_x38",1,""),
            new opcode(0x39,"run_later",1,""),
            new opcode(0x3a,"opcode_x3a",1,""),
            new opcode(0x3b,"run_local_later",1,""),
            new opcode(0x3c,"opcode_x3c",1,""),
            new opcode(0x3d,"skip_cut_to",1,""),
            new opcode(0x3e,"opcode_x3e",0,""),
            new opcode(0x3f,"opcode_x3f",1,""),
            new opcode(0x40,"opcode_x40",2,""),
            new opcode(0x41,"say",1,""),
            new opcode(0x42,"opcode_x42",2,""),
            new opcode(0x43,"actor_says",2,""),
            new opcode(0x44,"opcode_x44",3,""),
            new opcode(0x45,"opcode_x45",4,""),
            new opcode(0x46,"opcode_x46",4,""),
            new opcode(0x47,"pos_color_say",5,""),
            new opcode(0x48,"opcode_x48",5,""),
            new opcode(0x49,"opcode_x49",2,""),
            new opcode(0x4a,"wait_speech",0,""),
            new opcode(0x4b,"wait_actor_speech",1,""),
            new opcode(0x4c,"opcode_x4c",0,""),
            new opcode(0x4d,"opcode_x4d",2,""),
            new opcode(0x4e,"opcode_x4e",1,""),
            new opcode(0x4f,"opcode_x4f",2,""),
            new opcode(0x50,"opcode_x50",1,""),
            new opcode(0x51,"opcode_x51",2,""),
            new opcode(0x52,"opcode_x52",1,""),
            new opcode(0x53,"opcode_x53",1,""),
            new opcode(0x54,"ask_about_at",5,""),
            new opcode(0x55,"print_color_pos",4,""),
            new opcode(0x56,"say_frames",2,""),
            new opcode(0x57,"wait_said",0,""),
            new opcode(0x58,"opcode_x58",1,""),
            new opcode(0x59,"opcode_x59",1,""),
            new opcode(0x5a,"opcode_x5a",1,""),
            new opcode(0x5b,"opcode_x5b",1,""),
            new opcode(0x5c,"opcode_x5c",1,""),
            new opcode(0x5d,"opcode_x5d",2,""),
            new opcode(0x5e,"opcode_x5e",1,""),
            new opcode(0x5f,"opcode_x5f",4,""),
            new opcode(0x60,"search_list",4,""),
            new opcode(0x61,"opcode_x61",3,""),
            new opcode(0x62,"opcode_x62",3,""),
            new opcode(0x63,"actor_prop",3,""),
            new opcode(0x64,"opcode_x64",4,""),
            new opcode(0x65,"opcode_x65",4,""),
            new opcode(0x66,"opcode_x66",3,""),
            new opcode(0x67,"opcode_x67",3,""),
            new opcode(0x68,"opcode_x68",3,""),
            new opcode(0x69,"opcode_x69",1,""),
            new opcode(0x6a,"opcode_x6a",2,""),
            new opcode(0x6b,"opcode_x6b",2,""),
            new opcode(0x6c,"opcode_x6c",2,""),
            new opcode(0x6d,"inc",1,""),
            new opcode(0x6e,"opcode_x6e",2,""),
            new opcode(0x6f,"dec",1,""),
            new opcode(0x70,"assign",2,""),
            new opcode(0x71,"opcode_x71",2,""),
            new opcode(0x72,"one",1,""),
            new opcode(0x73,"zero",1,""),
            new opcode(0x74,"opcode_x74",1,""),
            new opcode(0x75,"opcode_x75",1,""),
            new opcode(0x76,"opcode_x76",1,""),
            new opcode(0x77,"player_room_pos",2,""),
            new opcode(0x78,"opcode_x78",3,""),
            new opcode(0x79,"move_actor_room_anim",3,""),
            new opcode(0x7a,"opcode_x7a",4,""),
            new opcode(0x7b,"opcode_x7b",1,""),
            new opcode(0x7c,"toggle_exit_state",1,""),
            new opcode(0x7d,"opcode_x7d",2,""),
            new opcode(0x7e,"opcode_x7e",2,""),
            new opcode(0x7f,"opcode_x7f",2,""),
            new opcode(0x80,"opcode_x80",4,""),
            new opcode(0x81,"opcode_x81",3,""),
            new opcode(0x82,"opcode_x82",2,""),
            new opcode(0x83,"opcode_x83",2,""),
            new opcode(0x84,"opcode_x84",1,""),
            new opcode(0x85,"opcode_x85",2,""),
            new opcode(0x86,"opcode_x86",3,""),
            new opcode(0x87,"opcode_x87",0,""),
            new opcode(0x88,"opcode_x88",1,""),
            new opcode(0x89,"opcode_x89",2,""),
            new opcode(0x8a,"opcode_x8a",3,""),
            new opcode(0x8b,"opcode_x8b",0,""),
            new opcode(0x8c,"opcode_x8c",1,""),
            new opcode(0x8d,"opcode_x8d",3,""),
            new opcode(0x8e,"opcode_x8e",0,""),
            new opcode(0x8f,"opcode_x8f",1,""),
            new opcode(0x90,"opcode_x90",2,""),
            new opcode(0x91,"opcode_x91",1,""),
            new opcode(0x92,"opcode_x92",2,""),
            new opcode(0x93,"opcode_x93",2,""),
            new opcode(0x94,"opcode_x94",0,""),
            new opcode(0x95,"unlock_control",0,""),
            new opcode(0x96,"lock_control",0,""),
            new opcode(0x97,"opcode_x97",0,""),
            new opcode(0x98,"opcode_x98",0,""),
            new opcode(0x99,"wait_player_exit",0,""),
            new opcode(0x9a,"wait_actor_exit",1,""),
            new opcode(0x9b,"delay",1,""),
            new opcode(0x9c,"wait_actor_time",2,""),
            new opcode(0x9d,"set_player",1,""),
            new opcode(0x9e,"warp_frame",1,""),
            new opcode(0x9f,"set_frame",2,""),
            new opcode(0xa0,"opcode_xa0",2,""),
            new opcode(0xa1,"opcode_xa1",2,""),
            new opcode(0xa2,"opcode_xa2",3,""),
            new opcode(0xa3,"opcode_xa3",3,""),
            new opcode(0xa4,"opcode_xa4",1,""),
            new opcode(0xa5,"opcode_xa5",2,""),
            new opcode(0xa6,"opcode_xa6",2,""),
            new opcode(0xa7,"opcode_xa7",3,""),
            new opcode(0xa8,"opcode_xa8",3,""),
            new opcode(0xa9,"opcode_xa9",2,""),
            new opcode(0xaa,"opcode_xaa",1,""),
            new opcode(0xab,"opcode_xab",1,""),
            new opcode(0xac,"opcode_xac",2,""),
            new opcode(0xad,"turn_actor",2,""),
            new opcode(0xae,"opcode_xae",3,""),
            new opcode(0xaf,"opcode_xaf",0,""),
            new opcode(0xb0,"opcode_xb0",1,""),
            new opcode(0xb1,"opcode_xb1",1,""),
            new opcode(0xb2,"opcode_xb2",1,""),
            new opcode(0xb3,"opcode_xb3",1,""),
            new opcode(0xb4,"opcode_xb4",1,""),
            new opcode(0xb5,"opcode_xb5",2,""),
            new opcode(0xb6,"opcode_xb6",2,""),
            new opcode(0xb7,"opcode_xb7",2,""),
            new opcode(0xb8,"opcode_xb8",2,""),
            new opcode(0xb9,"set_actor_anim",2,""),
            new opcode(0xba,"opcode_xba",4,""),
            new opcode(0xbb,"opcode_xbb",4,""),
            new opcode(0xbc,"hide_actor",1,""),
            new opcode(0xbd,"set_anim_pnt",1,""),
            new opcode(0xbe,"set_anim",1,""),
            new opcode(0xbf,"opcode_xbf",3,""),
            new opcode(0xc0,"opcode_xc0",3,""),
            new opcode(0xc1,"opcode_xc1",0,""),
            new opcode(0xc2,"add_anim",1,""),
            new opcode(0xc3,"opcode_xc3",3,""),
            new opcode(0xc4,"opcode_xc4",3,""),
            new opcode(0xc5,"opcode_xc5",1,""),
            new opcode(0xc6,"wait_anim",1,""),
            new opcode(0xc7,"play_movie_speed",2,""),
            new opcode(0xc8,"set_backdrop",1,""),
            new opcode(0xc9,"set_backdrop_def",1,""),
            new opcode(0xca,"opcode_xca",2,""),
            new opcode(0xcb,"load_graph",1,""),
            new opcode(0xcc,"fullscreen",1,""),
            new opcode(0xcd,"opcode_xcd",0,""),
            new opcode(0xce,"start_cut",0,""),
            new opcode(0xcf,"fadeout",0,""),
            new opcode(0xd0,"fadeout_part",0,""),
            new opcode(0xd1,"fadein",0,""),
            new opcode(0xd2,"fadein_part",0,""),
            new opcode(0xd3,"opcode_xd3",0,""),
            new opcode(0xd4,"opcode_xd4",2,""),
            new opcode(0xd5,"opcode_xd5",2,""),
            new opcode(0xd6,"change_room",1,""),
            new opcode(0xd7,"opcode_xd7",0,""),
            new opcode(0xd8,"opcode_xd8",0,""),
            new opcode(0xd9,"opcode_xd9",4,""),
            new opcode(0xda,"opcode_xda",0,""),
            new opcode(0xdb,"add_rect",5,""),
            new opcode(0xdc,"opcode_xdc",0,""),
            new opcode(0xdd,"opcode_xdd",5,""),
            new opcode(0xde,"opcode_xde",0,""),
            new opcode(0xdf,"add_actor_frame",6,""),
            new opcode(0xe0,"opcode_xe0",1,""),
            new opcode(0xe1,"opcode_xe1",3,""),
            new opcode(0xe2,"opcode_xe2",0,""),
            new opcode(0xe3,"opcode_xe3",3,""),
            new opcode(0xe4,"opcode_xe4",4,""),
            new opcode(0xe5,"hide_exits",0,""),
            new opcode(0xe6,"run_room",1,""),
            new opcode(0xe7,"opcode_xe7",0,""),
            new opcode(0xe8,"opcode_xe8",1,""),
            new opcode(0xe9,"opcode_xe9",1,""),
            new opcode(0xea,"opcode_xea",2,""),
            new opcode(0xeb,"opcode_xeb",0,""),
            new opcode(0xec,"opcode_xec",1,""),
            new opcode(0xed,"opcode_xed",2,""),
            new opcode(0xee,"opcode_xee",1,""),
            new opcode(0xef,"random",2,""),
            new opcode(0xf0,"load_sfx",1,""),
            new opcode(0xf1,"opcode_xf1",2,""),
            new opcode(0xf2,"opcode_xf2",1,""),
            new opcode(0xf3,"opcode_xf3",0,""),
            new opcode(0xf4,"play_music",1,""),
            new opcode(0xf5,"opcode_xf5",0,""),
            new opcode(0xf6,"opcode_xf6",0,""),
            new opcode(0xf7,"stop_music",0,""),
            new opcode(0xf8,"opcode_xf8",0,""),
            new opcode(0xf9,"sound_on",2,""),
            new opcode(0xfa,"opcode_xfa",0,""),
            new opcode(0xfb,"opcode_xfb",0,""),
            new opcode(0xfc,"quit",1,""),
            new opcode(0xfd,"opcode_xfd",1,""),
        };
    }
}

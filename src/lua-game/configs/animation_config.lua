_ANIMATION_HERO = {
 --  ["move_x"] = -15,
   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_HERO .. "model_move.png",
	 ["clipx"] = 8,
	 ["clipy"] = 8,
      },
      ["fight_sprite"] = {
	 ["path"] = PATH_HERO .. "model_fight.png",
	 ["clipx"] = 6,
	 ["clipy"] = 8,
      },
   },
   ["sounds"] = {
      ["move_sound"] = {
	 ["path"] = PATH_SOUNDS .. "move1.ogg"
      },
      ["spell_sound"] = {
	 ["path"] = PATH_SOUNDS .. "scratch.wav"
      }
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {2,3,4,5,6,7}},
      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},
      ["attack"] = {
	 ["sprite"] = "fight_sprite",
	 ["frames"] = {0,1,2,3,4,5},
	 ["sound"] = {
	    ["sound"] = "move_sound",
	    ["sound_start"] = {1}}},
      ["spell"] = {
	 ["sprite"] = "fight_sprite",
	 ["frames"] = {0,1,2,3,4,5},
	 ["sound"] = {
	    ["sound"] = "spell_sound",
	    ["sound_start"] = {1}}},
      
   }
}

_ANIMATION_TUNIC = {
   ["move_x"] = 12,
   ["move_y"] = 24,
   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_HERO .. "tunic_comprim.png",
	 ["clipx"] = 8,
	 ["clipy"] = 8,
      },
      ["fight_sprite"] = {
	 ["path"] = PATH_HERO .. "tunic_fight.png",
	 ["clipx"] = 6,
	 ["clipy"] = 8,
      },
  
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {2,3,4,5,6,7}
      },
      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},
      ["attack"] = {
	 ["sprite"] = "fight_sprite",
	 ["frames"] = {0,1,2,3,4,5}
      },   
   }
}
_ANIMATION_TROUSERS = {
   ["move_x"] = 19,
   ["move_y"] = 40,
   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_HERO .. "trousers_comprim.png",
	 ["clipx"] = 8,
	 ["clipy"] = 8,
      },
      ["fight_sprite"] = {
	 ["path"] = PATH_HERO .. "trousers_fight.png",
	 ["clipx"] = 6,
	 ["clipy"] = 8,
      }
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {2,3,4,5,6,7}
      },
      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},
      ["attack"] = {
	 ["sprite"] = "fight_sprite",
	 ["frames"] = {0,1,2,3,4,5}
      },   
   }
}

_ANIMATION_HELMET = {
   ["move_x"] = 22,
   ["move_y"] = 10,
   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_HERO .. "helmet.png",
	 ["clipx"] = 8,
	 ["clipy"] = 8,
      },
      ["fight_sprite"] = {
	 ["path"] = PATH_HERO .. "helmet_fight.png",
	 ["clipx"] = 6,
	 ["clipy"] = 8,
      }
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {2,3,4,5,6,7}
      },
      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},
      ["attack"] = {
	 ["sprite"] = "fight_sprite",
	 ["frames"] = {0,1,2,3,4,5}
      },   
   }
}


_ANIMATION_HAIR = {
   ["move_x"] = 37-15,
   ["move_y"] = 1,
   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_HERO .. "hair_comprim.png",
	 ["clipx"] = 8,
	 ["clipy"] = 8,
      }
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {2,3,4,5,6,7}
      },
      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}}
   }
}

_ANIMATION_BOOTS = {
   ["move_x"] = 0,
   ["move_y"] = 45,
   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_HERO .. "boots_comprim.png",
	 ["clipx"] = 8,
	 ["clipy"] = 8,
      },
      ["fight_sprite"] = {
	 ["path"] = PATH_HERO .. "boots_fight.png",
	 ["clipx"] = 6,
	 ["clipy"] = 8,
      }
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {2,3,4,5,6,7}
      },
      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},
      ["attack"] = {
	 ["sprite"] = "fight_sprite",
	 ["frames"] = {0,1,2,3,4,5}
      },   
   }
}

_ANIMATION_SWORD = {
   ["move_x"] = -33,
   ["move_y"] = -3,
   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_HERO .. "sword_comprim.png",
	 ["clipx"] = 8,
	 ["clipy"] = 8,
      },
      ["fight_sprite"] = {
	 ["path"] = PATH_HERO .. "sword_fight.png",
	 ["clipx"] = 6,
	 ["clipy"] = 8,
      }
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {2,3,4,5,6,7}
      },
      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},
      ["attack"] = {
	 ["sprite"] = "fight_sprite",
	 ["frames"] = {0,1,2,3,4,5}
      }, 
   }
}


_BINDING_EQUIPMENT = {
   {"model","trousers","boots","tunic","hair","hat","right_gloves","left_gloves",
    "right_hand","left_hand"},

   {"right_gloves","right_hand","model","trousers","boots","tunic","hair","hat",
    "left_hand","left_gloves"},

   {"right_gloves","right_hand","model","trousers","boots","tunic","hair","hat",
    "left_hand","left_gloves"},

   {"right_gloves","right_hand","model","trousers","boots","tunic","hair","hat",
    "left_hand","left_gloves"},

   {"left_hand","right_hand","right_gloves","left_gloves","model","trousers","boots",
    "tunic","hair","hat"},

   {"left_gloves","left_hand","model","trousers","boots","tunic","hair","hat",
    "right_hand","right_gloves"},

   {"left_gloves","left_hand","model","trousers","boots","tunic","hair","hat",
    "right_hand","right_gloves"},

   {"left_gloves","left_hand","model","trousers","boots","tunic","hair","hat",
    "right_hand","right_gloves"},
}

_ANIMATION_AMAZON = {
   ["move_x"] = -15,
   ["move_y"] = 0,
   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_SPRITES .. "amazon.png",
	 ["clipx"] = 8,
	 ["clipy"] = 8,
      }      
   },
   ["sounds"] = {
      ["move_sound"] = {
	 ["path"] = PATH_SOUNDS .. "scratch.wav"
      }
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {2,3,4,5,6,7},
	 ["sound"] = {
	    ["sound"] = "move_sound",
	    ["sound_start"] = {1}},
   },
      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}}
   }
}

_ANIMATION_SPIDERMUT = {

   ["move_x"] = -50,
   ["move_y"] = 50,
   ["matricies_collision"] = 2,
   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_SPRITES .. "spidermut.png",
	 ["clipx"] = 11,
	 ["clipy"] = 8,
      }      
   },
   ["sounds"] = {
      ["move_sound"] = {
	 ["path"] = PATH_SOUNDS .. "scratch.wav"
      }
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {1,2,3,4,5},
   },
      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},
      ["attack"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {6,7,8,9,10}},
   }            
}


_ANIMATION_SPIDER = {
   ["move_x"] = -30,
   ["move_y"] = 10,

   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_SPRITES .. "spider_test.png",
	 ["clipx"] = 12,
	 ["clipy"] = 8,
      }      
   },
   ["sounds"] = {
      ["move_sound"] = {
	 ["path"] = PATH_SOUNDS .. "scratch.wav"
      }
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {1,2,3,4,5,6,7}},

      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},
      ["attack"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {7,8,9,10,11}},
   }            
}

_ANIMATION_FIREBALL = {
   ["move_x"] = 0,
   ["move_y"] = -40,

   ["sprites"] = {
      ["move_sprite"] = {
	 ["path"] = PATH_SPRITES .. "fireball.png",
	 ["clipx"] = 1,
	 ["clipy"] = 8,
      }      
   },
   ["sounds"] = {
      ["move_sound"] = {
	 ["path"] = PATH_SOUNDS .. "scratch.wav"
      }
   },
   ["animations"] = {
      ["move"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},

      ["stay"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},
      ["attack"] = {
	 ["sprite"] = "move_sprite",
	 ["frames"] = {0}},
   }            
}
local Attack = {}

function Attack.count_spell_attack(attacker, defender)
   local result = math.random(attacker.stats.attack) - (defender.wisdom*2)
   if result < 0 then
      result = 0
   end
   return result
end
function Attack.count_mellee_attack(attacker_stats, defender_stats)
   local attack = math.floor(attacker_stats.strengh*2 + attacker_stats.dexterity + 
				attacker_stats.attack)
   local defend = math.floor(defender_stats.strengh/4 + defender_stats.dexterity + 
				defender_stats.armor)
   local tmp_a = (1/(attacker_stats.wisdom/3)) * attack
   local tmp_d = (1/(defender_stats.wisdom/3)) * defend
   if attack- tmp_a > 0 then
      attack = math.random(attack - tmp_a) + tmp_a
   end
   if defend - tmp_d > 0 then
      defend = math.random(defend - tmp_d) + tmp_d
   end
   local r =  attack - defend
   if r <= 0 then r = 0 end
   

   return r
end

return Attack
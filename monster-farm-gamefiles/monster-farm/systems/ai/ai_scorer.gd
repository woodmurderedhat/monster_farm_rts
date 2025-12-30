## AI Scoring system for decision-making across combat and farm AI
## Provides unified scoring logic for target selection, ability usage, and job priority
extends Node
class_name AIScorer

## Score a potential action based on multiple weighted factors
static func score_action(context: Dictionary, weights: Dictionary) -> float:
	var score := 0.0
	
	for key in weights:
		if context.has(key):
			score += context[key] * weights[key]
	
	return score

## Score a combat target based on threat, distance, health, and DNA affinity
static func score_combat_target(monster: Node, target: Node, dna_config: Dictionary) -> float:
	if not is_instance_valid(target):
		return 0.0
	
	var score := 0.0
	var distance: float = monster.global_position.distance_to(target.global_position)
	
	# Base threat value
	if target.has_meta("threat_value"):
		score += target.get_meta("threat_value") * 2.0
	
	# Distance penalty (prefer closer targets)
	var max_range := 500.0
	if distance < max_range:
		score += (1.0 - distance / max_range) * 1.5
	else:
		return 0.0  # Too far
	
	# Health percentage (prefer low health targets if aggressive)
	if target.has_node("HealthComponent"):
		var health_comp = target.get_node("HealthComponent")
		var health_pct = health_comp.current_health / health_comp.max_health
		
		# Aggressive AI prefer wounded targets
		if dna_config.get("aggression_level", 0.5) > 0.6:
			score += (1.0 - health_pct) * 1.0
	
	# DNA-based affinity modifiers
	if dna_config.has("target_priority_tags"):
		if target.has_meta("tags"):
			var target_tags = target.get_meta("tags")
			for tag in dna_config["target_priority_tags"]:
				if tag in target_tags:
					score += 2.0
	
	return max(0.0, score)

## Score a job for a farm monster based on needs, DNA affinity, and priority
static func score_job(monster: Node, job: Resource, needs: Dictionary, dna_config: Dictionary) -> float:
	var score: float = job.base_priority if job.has("base_priority") else 1.0
	
	# DNA work affinity
	if dna_config.has("work_affinity"):
		var affinity = dna_config["work_affinity"]
		if affinity.has(job.work_type):
			score += affinity[job.work_type] * 2.0
	
	# Need urgency - jobs that satisfy urgent needs get boosted
	if job.has("satisfies_need"):
		var need_type = job.satisfies_need
		if needs.has(need_type):
			var need_urgency = 1.0 - needs[need_type]  # Lower value = more urgent
			score += need_urgency * 3.0
	
	# Stress penalty - stressed monsters avoid work
	if monster.has_node("StressComponent"):
		var stress = monster.get_node("StressComponent").stress_level
		score -= stress * 0.5
	
	# Danger penalty - low courage monsters avoid dangerous jobs
	if job.has("danger_level"):
		var courage = dna_config.get("courage", 0.5)
		if courage < job.danger_level:
			score -= (job.danger_level - courage) * 2.0
	
	# Tag requirements
	if job.has("required_tags") and monster.has_meta("tags"):
		var monster_tags = monster.get_meta("tags")
		for tag in job.required_tags:
			if not tag in monster_tags:
				return 0.0  # Can't do this job
	
	if job.has("forbidden_tags") and monster.has_meta("tags"):
		var monster_tags = monster.get_meta("tags")
		for tag in job.forbidden_tags:
			if tag in monster_tags:
				return 0.0  # Forbidden from this job
	
	return max(0.0, score)

## Score an ability for use based on tactical situation
static func score_ability(monster: Node, ability: Dictionary, target: Node, tactical_context: Dictionary) -> float:
	var score := 1.0
	
	# Check if ability is on cooldown
	if ability.get("cooldown_remaining", 0.0) > 0.0:
		return 0.0
	
	# Check energy/resource cost
	if monster.has_node("StaminaComponent"):
		var stamina = monster.get_node("StaminaComponent")
		if ability.has("energy_cost") and stamina.current_stamina < ability.energy_cost:
			return 0.0
	
	# Range check
	if is_instance_valid(target) and ability.has("ability_range"):
		var distance = monster.global_position.distance_to(target.global_position)
		if distance > ability.ability_range:
			return 0.0  # Out of range
	
	# Tactical context modifiers
	if tactical_context.has("ally_count") and ability.has("is_aoe"):
		if ability.is_aoe:
			score += tactical_context.get("enemy_density", 0.0) * 2.0
	
	if tactical_context.has("self_health_pct"):
		var health_pct = tactical_context["self_health_pct"]
		if ability.get("is_defensive", false) and health_pct < 0.5:
			score += (1.0 - health_pct) * 3.0
	
	# DNA-based ability preference
	if monster.has_meta("ai_config"):
		var ai_config = monster.get_meta("ai_config")
		if ai_config.has("ability_preferences"):
			var prefs = ai_config["ability_preferences"]
			if prefs.has(ability.get("ability_id", "")):
				score += prefs[ability.ability_id]
	
	return max(0.0, score)

## Calculate a priority value for retreat/flee behavior
static func should_retreat(monster: Node, dna_config: Dictionary, tactical_context: Dictionary) -> float:
	var retreat_score := 0.0
	
	# Health threshold
	if monster.has_node("HealthComponent"):
		var health = monster.get_node("HealthComponent")
		var health_pct = health.current_health / health.max_health
		
		# Cowardly monsters retreat earlier
		var retreat_threshold = 1.0 - dna_config.get("courage", 0.5)
		if health_pct < retreat_threshold:
			retreat_score += (retreat_threshold - health_pct) * 5.0
	
	# Overwhelming odds
	if tactical_context.has("enemy_count") and tactical_context.has("ally_count"):
		var odds = float(tactical_context["enemy_count"]) / max(1.0, tactical_context["ally_count"])
		if odds > 2.0:
			retreat_score += (odds - 2.0) * 2.0
	
	# Stress influence
	if monster.has_node("StressComponent"):
		var stress = monster.get_node("StressComponent").stress_level
		retreat_score += stress * 1.5
	
	return retreat_score

/// Room Start: troca o visual do Talai conforme a sala (mundo da história = talaiB; escola = normal)
talai_apply_form();

// ── Companion Rasiel / Rodapé ─────────────────────────────────────
// Entra em rm_inicio e anda com o player daí em diante. A criação foi
// centralizada em scr_party porque o ObjPlayer recriado após uma batalha
// NÃO dispara Room Start (é criado pelo obj_settings no meio da sala).
// Sem isso o Rodapé desaparecia até o jogador trocar de sala.
companion_ensure_spawn();

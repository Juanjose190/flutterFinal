import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../data_repository.dart';
import '../ui/widgets/glass_card.dart';

class VerHorarioScreen extends StatefulWidget {
  final Horario? horario;
  const VerHorarioScreen({super.key, this.horario});

  @override
  State<VerHorarioScreen> createState() => _VerHorarioScreenState();
}

class _VerHorarioScreenState extends State<VerHorarioScreen> {
  final repo = DataRepository.instance;
  HorarioStatus? _status;

  @override
  void initState() {
    super.initState();
    _status = widget.horario?.status;
  }

  void _updateStatus(HorarioStatus? s) {
    if (widget.horario != null && s != null) {
      repo.updateHorarioStatus(widget.horario!.id, s);
      setState(() => _status = s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aprobado = repo.countByStatus(HorarioStatus.aprobado);
    final pendiente = repo.countByStatus(HorarioStatus.pendiente);
    final borrador = repo.countByStatus(HorarioStatus.borrador);

    final horario = widget.horario;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Horario generado')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            sliver: SliverToBoxAdapter(
              child: horario == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: const [Icon(CupertinoIcons.chart_bar), SizedBox(width: 8), Text('Resumen de horarios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))]),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: const [
                                  Chip(label: Text('aprobado'), avatar: Icon(Icons.check_circle, color: Colors.green)),
                                  Chip(label: Text('pendiente'), avatar: Icon(Icons.hourglass_bottom, color: Colors.orange)),
                                  Chip(label: Text('borrador'), avatar: Icon(Icons.edit, color: Colors.blue)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('aprobado: $aprobado • pendiente: $pendiente • borrador: $borrador'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Genera un horario desde la opción "Generar horario con IA".'),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassCard(
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.square_list),
                              const SizedBox(width: 8),
                              const Text('Estado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: DropdownButton<HorarioStatus>(
                                  key: ValueKey(_status),
                                  value: _status,
                                  underline: const SizedBox.shrink(),
                                  items: const [
                                    DropdownMenuItem(value: HorarioStatus.aprobado, child: Text('aprobado')),
                                    DropdownMenuItem(value: HorarioStatus.pendiente, child: Text('pendiente')),
                                    DropdownMenuItem(value: HorarioStatus.borrador, child: Text('borrador')),
                                  ],
                                  onChanged: _updateStatus,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: const [Icon(CupertinoIcons.person), SizedBox(width: 8), Text('Docentes seleccionados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final id in horario!.docenteIds)
                                    Chip(label: Text(repo.docentes.firstWhere((d) => d.id == id).nombre)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: const [Icon(CupertinoIcons.book), SizedBox(width: 8), Text('Materias seleccionadas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final id in horario.materiaIds)
                                    Chip(label: Text(repo.materias.firstWhere((m) => m.id == id).nombre)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: const [Icon(CupertinoIcons.building_2_fill), SizedBox(width: 8), Text('Aulas seleccionadas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final id in horario.aulaIds)
                                    Chip(label: Text(repo.aulas.firstWhere((a) => a.id == id).nombre)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Row(children: [Icon(CupertinoIcons.calendar), SizedBox(width: 8), Text('Horario (vista simplificada)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
                              SizedBox(height: 8),
                              ListTile(title: Text('Lunes 8:00 - Matemáticas - Aula 101')),
                              ListTile(title: Text('Martes 10:00 - Lengua - Aula 202')),
                              ListTile(title: Text('Miércoles 9:00 - Historia - Laboratorio')),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
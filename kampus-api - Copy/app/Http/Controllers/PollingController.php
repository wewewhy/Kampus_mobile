<?php

namespace App\Http\Controllers;

use App\Models\Polling;
use App\Models\PollingOption;
use App\Models\PollingVote;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PollingController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $pollings = Polling::with(['options', 'votes' => function ($query) use ($userId) {
            $query->where('user_id', $userId);
        }])
            ->where('status', 'aktif')
            ->latest()
            ->get()
            ->map(function ($polling) {
                return [
                    'id' => $polling->id,
                    'judul' => $polling->judul,
                    'deskripsi' => $polling->deskripsi,
                    'status' => $polling->status,
                    'created_at' => $polling->created_at,
                    'options' => $polling->options->map(fn ($option) => [
                        'id' => $option->id,
                        'label' => $option->label,
                        'votes' => $option->votes,
                    ])->values(),
                    'voters' => $polling->votes->pluck('user_id')->values(),
                ];
            });

        return response()->json(['data' => $pollings], 200);
    }

    public function store(Request $request)
    {
        $request->validate([
            'judul' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'options' => 'required|array|min:2',
            'options.*' => 'required|string|max:255',
        ]);

        $polling = DB::transaction(function () use ($request) {
            $polling = Polling::create([
                'judul' => $request->judul,
                'deskripsi' => $request->deskripsi,
                'status' => 'aktif',
            ]);

            foreach ($request->options as $option) {
                $polling->options()->create(['label' => $option]);
            }

            return $polling->load('options');
        });

        return response()->json(['message' => 'Polling berhasil dibuat', 'data' => $polling], 201);
    }

    public function vote(Request $request, Polling $polling)
    {
        $request->validate([
            'option_id' => 'required|exists:polling_options,id',
        ]);

        $option = PollingOption::where('polling_id', $polling->id)->findOrFail($request->option_id);
        $userId = $request->user()->id;

        $alreadyVoted = PollingVote::where('polling_id', $polling->id)
            ->where('user_id', $userId)
            ->exists();

        if ($alreadyVoted) {
            return response()->json(['message' => 'Polling sudah pernah diisi'], 409);
        }

        DB::transaction(function () use ($polling, $option, $userId) {
            PollingVote::create([
                'polling_id' => $polling->id,
                'polling_option_id' => $option->id,
                'user_id' => $userId,
            ]);
            $option->increment('votes');
        });

        return response()->json(['message' => 'Vote berhasil disimpan'], 201);
    }
}

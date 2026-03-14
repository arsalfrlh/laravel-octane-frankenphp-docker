<?php

namespace App\Jobs;

use App\Models\Song;
use FFMpeg\Format\Video\X264;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Queue\SerializesModels;
use ProtoneMedia\LaravelFFMpeg\Support\FFMpeg;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;

class SongHlsProcess implements ShouldQueue
{
    use Queueable, Dispatchable, SerializesModels;
    protected Song $song;

    /**
     * Create a new job instance.
     */
    public function __construct($song)
    {
        $this->song = $song;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        $song = $this->song;
        $hlsPath = "hls/" . $song->title . '_' . time();
        $m3u8Name = $song->title . ".m3u8";
        Storage::disk('public')->makeDirectory($hlsPath);
        $format = new X264('aac', 'libx264');
        $format->setAudioCodec('aac');
        FFMpeg::fromDisk('public')->open($song->audio_raw_path)->exportForHLS()->setSegmentLength(20)->addFormat($format)->toDisk('public')->save($hlsPath . '/' . $m3u8Name);
        $duration = FFMpeg::fromDisk('public')->open($song->audio_raw_path)->getDurationInSeconds();
        $audioPath = $hlsPath . '/' . $m3u8Name;
        $song->update([
            'audio_path' => $audioPath,
            'duration' => $duration
        ]);
    }
}

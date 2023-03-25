import React from "react";
import "./Footer.css";
import { useState, useRef, useEffect } from "react";
import PlayCircleIcon from "@mui/icons-material/PlayCircle";
import SkipPreviousIcon from "@mui/icons-material/SkipPrevious";
import SkipNextIcon from "@mui/icons-material/SkipNext";
import ShuffleIcon from "@mui/icons-material/Shuffle";
import RepeatIcon from "@mui/icons-material/Repeat";
import PlaylistPlayIcon from "@mui/icons-material/PlaylistPlay";
import VolumeDownIcon from "@mui/icons-material/VolumeDown";
import FavoriteBorderIcon from "@mui/icons-material/FavoriteBorder";
import FavoriteIcon from "@mui/icons-material/Favorite";
import PauseCircleIcon from "@mui/icons-material/PauseCircle";
import VolumeOffIcon from "@mui/icons-material/VolumeOff";
import VolumeMuteIcon from "@mui/icons-material/VolumeMute";
import VolumeUpIcon from "@mui/icons-material/VolumeUp";
import { Grid, Slider } from "@mui/material";

// let audio = new Audio(
//   "https://gateway.pinata.cloud/ipfs/QmaVDGX5SVPBFMEbA4LgkZ33zVngf2L9A6si3sdmfR6Hja"
// );

function Footer() {
  const [liked, setLiked] = useState(false);
  const [isPlaying, setIsPlaying] = useState(true);
  const [isMute, setIsMute] = useState(false);
  const [volume, setVolume] = useState(30);
  const [elapsed, setElapsed] = useState();
  const [progress, setProgess] = useState();
  const [duration, setDuration] = useState();

  const progressBar = useRef();
  const volumeBar = useRef();
  const audioPlayer = useRef();

  useEffect(() => {
    if (audioPlayer) {
      audioPlayer.current.volume = volume / 100;
    }

    if (isPlaying) {
      setInterval(() => {
        const _duration = Math.floor(audioPlayer?.current?.duration);
        const _elapsed = Math.floor(audioPlayer?.current?.currentTime);
        const _prog = Math.floor(_elapsed / 100);
        setElapsed(formatTime(_elapsed));
        setDuration(_duration);
        console.log(_elapsed);
        console.log("Prog", _prog);
        setProgess(_prog);
      }, 100);
    }
  }, [volume, isPlaying]);

  function formatTime(time) {
    const minutes =
      Math.floor(time / 60) < 10
        ? `0${Math.floor(time / 60)}`
        : Math.floor(time / 60);
    const seconds =
      Math.floor(time % 60) < 10
        ? `0${Math.floor(time % 60)}`
        : Math.floor(time % 60);
    return `${minutes}:${seconds}`;
  }

  const likeSong = (e) => {
    e.preventDefault();
    if (liked) {
      setLiked(false);
    } else {
      setLiked(true);
    }
  };

  const togglePlay = (e) => {
    e.preventDefault();
    if (isPlaying) {
      setIsPlaying(false);
      audioPlayer.current.play();
    } else {
      setIsPlaying(true);
      audioPlayer.current.pause();
    }
  };

  const mute = (e) => {
    e.preventDefault();
    if (isMute) {
      setIsMute(false);
      setVolume(20);
    } else {
      setIsMute(true);
      setVolume(0);
    }
  };

  return (
    <div className="footer">
      <div className="footer__left">
        <img
          src="https://c.saavncdn.com/191/Kesariya-From-Brahmastra-Hindi-2022-20220717092820-500x500.jpg"
          alt=""
          className="footer__albumLogo"
        />
        <div className="footer__songInfo">
          <h4>Kesariya</h4>
          <p>Pritam, Arijit Singh </p>
        </div>
        <div className="footer__like" onClick={likeSong}>
          {liked ? (
            <FavoriteIcon className="footer__icon" />
          ) : (
            <FavoriteBorderIcon className="footer__icon" />
          )}
        </div>
      </div>
      <div className="footer__center">
        <ShuffleIcon className="footer__green" />
        <SkipPreviousIcon className="footer__icon" />
        <div onClick={togglePlay}>
          {isPlaying ? (
            <PlayCircleIcon fontSize="large" className="footer__icon" />
          ) : (
            <PauseCircleIcon fontSize="large" className="footer__icon" />
          )}
        </div>
        <SkipNextIcon className="footer__icon" />
        <RepeatIcon className="footer__green" />

        <div className="footer__slider">
          <audio
            src="https://gateway.pinata.cloud/ipfs/QmaVDGX5SVPBFMEbA4LgkZ33zVngf2L9A6si3sdmfR6Hja"
            ref={audioPlayer}
          />
          <Slider
            sx={{
              "& .MuiSlider-thumb": {
                color: "white",
                display: "none",
              },
              "& .MuiSlider-track": {
                color: "white",
              },
              "& .MuiSlider-rail": {
                color: "white",
              },
            }}
            // value={progress}
            // max={duration}
            min={0}
            max={100}
            value={volume}
            onChange={(e, v) => {
              setVolume(v);
            }}
          />
          <p>{elapsed}</p>
        </div>
      </div>
      <div className="footer__right">
        <Grid container spacing={2}>
          <Grid item>
            <PlaylistPlayIcon className="footer__icon" />
          </Grid>
          <Grid item>
            <div onClick={mute}>
              {volume == 0 ? (
                <VolumeOffIcon className="footer__icon" />
              ) : volume <= 30 ? (
                <VolumeDownIcon className="footer__icon" />
              ) : (
                <VolumeUpIcon className="footer__icon" />
              )}
            </div>
          </Grid>
          <Grid item xs>
            <Slider
              sx={{
                "& .MuiSlider-thumb": {
                  display: "none",
                },
              }}
              min={0}
              max={100}
              value={volume}
              onChange={(e, v) => {
                setVolume(v);
              }}
            />
          </Grid>
        </Grid>
      </div>
    </div>
  );
}

export default Footer;

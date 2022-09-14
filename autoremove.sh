#!/bin/sh

set -eu

echo "YTDLOR_AUTOREMOVE_INTERVAL=${YTDLOR_AUTOREMOVE_INTERVAL}"

rails runner 'Archive.order({:id => :asc}).offset(2).where({:status => Archive::Status::DONE}).where("updated_at < ?", ENV["YTDLOR_AUTOREMOVE_INTERVAL"].to_i.minutes.ago).destroy_all'

package main

import (
	"encoding/json"
	"fmt"
	"strings"

	"github.com/bogem/id3v2"
	"github.com/gogf/gf/v2/frame/g"
	"github.com/gogf/gf/v2/net/ghttp"

	"io/ioutil"
)

var musicList []Music

type Music struct {
	FileName string
	Title    string
	Artist   string
	Album    string
}

func errHandle(err error) {
	if err != nil {
		panic(err)
	}
}

func ParseMp3File(path string) Music {
	tag, err := id3v2.Open(path, id3v2.Options{Parse: true})
	errHandle(err)
	var music Music
	music.FileName = strings.Split(path, "/")[2]
	music.Title = tag.Title()
	music.Artist = tag.Artist()
	music.Album = tag.Album()
	tag.Close()
	return music
}

func ParseMp3Dir(pathName string) {
	fileList, err := ioutil.ReadDir(pathName)
	errHandle(err)

	for _, f := range fileList {
		if !f.IsDir() {
			music := ParseMp3File(fmt.Sprintf("%s/%s", pathName, f.Name()))
			musicList = append(musicList, music)
		}
	}
}

func main() {
	ParseMp3Dir("./musics")
	s := g.Server()

	s.BindHandler("/getMusics", func(r *ghttp.Request) {
		encodeJson, err := json.Marshal(musicList)
		errHandle(err)
		r.Response.Write(string(encodeJson))
	})
	s.SetIndexFolder(true)
	s.SetServerRoot("./musics")
	s.Run()
}

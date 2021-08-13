$(document).ready(function(){
  
  window.addEventListener('message', function(event) {
      var item = event.data;
      if (item.type === "ui") {
          AcKapiyiUsak(item.status)
      }
      if (event.data.type == "colors") {
        hairColors = createPalette(event.data.hairColors);
        AddPalettes();
        SetHairColor(event.data.hairColor);
      }

    if (event.data.type == "menutotals") {
        let drawTotal = event.data.drawTotal;
        let propDrawTotal = event.data.propDrawTotal;
        let textureTotal = event.data.textureTotal;
        let headoverlayTotal = event.data.headoverlayTotal;
        let skinTotal = event.data.skinTotal;
        let savedTotal = event.data.savedTotal;
        UpdateTotals(drawTotal, propDrawTotal, textureTotal, headoverlayTotal, skinTotal);
      }
    if (event.data.type == "clothesmenudata") {
        let drawables = event.data.drawables;
        let props = event.data.props;
        let drawtextures = event.data.drawtextures;
        let proptextures = event.data.proptextures;
        let skin = event.data.skin;
        UpdateInputs(drawables, props, drawtextures, proptextures, skin);
      }
  })

  document.onkeyup = function (data) {
      if (data.which == 27) {
        $("body").addClass("dark")
        $(".ode-panel-holder").fadeIn();
        $(".panel").fadeOut()
      }
      if (data.which == 100) {
        $.post('http://wiro_clotheshop/yon', JSON.stringify({
          yon: -15.0
        }))
      }
      if (data.which == 102) {
        $.post('http://wiro_clotheshop/yon', JSON.stringify({
          yon: 15.0
        }))
      }
  };

    $('.ode-panel-btn').on( "click", function() {
      let txt = $(this).text()
      if (txt == "SATIN AL") {
        $("body").removeClass("dark") 
        $(".ode-panel-holder").fadeOut();
        $.post('http://wiro_clotheshop/satinal', JSON.stringify({}))
      }
      else if (txt == "İPTAL ET") {
        $(".ode-panel-holder").fadeOut();
        $(".panel").fadeOut();
        $("body").removeClass("dark")
        $.post('http://wiro_clotheshop/iptal', JSON.stringify({
        }))
      }
      else if (txt == "GERİ DÖN") {
        $("body").removeClass("dark")
        $(".ode-panel-holder").fadeOut();
        $(".panel").fadeIn();
      }
    });

    $('.clothe-index-text').on('input', function() {
        enforceMinMax(this);
    });

    $('.clothe-buttons').on( "click", function() {
        $(this).next().toggle();
    });

    $('.fast-clothe-change-button').on( "click", function() {
      var text = $(this).children().first().children().first().text();
      if (text == "head" || text == "torso" || text == "leg") {
        $.post('http://wiro_clotheshop/cam', JSON.stringify({
          cam: text,
        }));
      }
      else {
        if(text == "shirt"){
          $.post('http://wiro_clotheshop/toggleclothes', JSON.stringify({name: "jackets"}))
          $.post('http://wiro_clotheshop/toggleclothes', JSON.stringify({name: "undershirts"}))
          $.post('http://wiro_clotheshop/toggleclothes', JSON.stringify({name: "torsos"}))
          $.post('http://wiro_clotheshop/toggleclothes', JSON.stringify({name: "vest"}))
          $.post('http://wiro_clotheshop/toggleclothes', JSON.stringify({name: "bags"}))
          $.post('http://wiro_clotheshop/toggleclothes', JSON.stringify({name: "neck"}))
          $.post('http://wiro_clotheshop/toggleclothes', JSON.stringify({name: "decals"}))
        }
        else{
          $.post('http://wiro_clotheshop/toggleclothes', JSON.stringify({
            name: text,
          }));
        }
      }
  });

    $('.alt-buttons').on( "click", function() {

        $(".minipanel-kiyafetler").each(function(){
            if($(this).css("display")=="flex"){
               $(this).hide();
            }
         });
        $('#' + $(this).text()).show()
    });

    $('.sagsol').on( "click", function() {
        $(this).prev().val(Number($(this).prev().val()) + 1)
        var el = $(this).prev();
        enforceMinMaxJq(el)
        inputChange($(this).prev())
    });

    $('.solsag').on( "click", function() {
        $(this).next().val(Number($(this).next().val()) - 1)
        var el = $(this).next();
        enforceMinMaxJq(el)
        inputChange($(this).next())
    });
    
    function enforceMinMax(el){
        if(el.value != ""){
          if(parseFloat(el.value) < parseFloat(el.min)){
            el.value = el.min;
          }
          if(parseFloat(el.value) > parseFloat(el.max)){
            el.value = el.max;
          }
        }
    }

    function enforceMinMaxJq(el){
        if(el.val() != ""){
          if(parseFloat(el.val()) < parseFloat(el.attr('min'))){
            el.val(el.attr('min'));
          }
          if(parseFloat(el.val()) > parseFloat(el.attr('max'))){
            el.val(el.attr('max'));
          }
        }
    }

    function AcKapiyiUsak(bool) {
      if (bool) {
        $(".panel").fadeIn(400)  
      }
      else {
          $(".panel").fadeOut(400)  
          $(".olustur-panel").fadeOut(400)  
      }
  }
  
  function UpdateInputs(drawables, props, drawtextures, proptextures, skin) {
    for (var i = 0; i < Object.keys(drawables).length; i++) {
        if (drawables[i][0] == "hair") {
            $('.hair').each(function() {
                $(this).find('.input-number').eq(0).val(drawables[i][1]);
            })
        }
        $("#" + drawables[i][0]).val(drawables[i][1]);
    }

    for (var i = 0; i < Object.keys(props).length; i++) {
        $("#" + props[i][0]).val(props[i][1]);
    }

    for (var i = 0; i < Object.keys(drawtextures).length; i++) {
        $("#" + drawtextures[i][0]).val(drawtextures[i][1]);
    }
    for (var i = 0; i < Object.keys(proptextures).length; i++) {
        $("#" + proptextures[i][0]).find('.input-number').eq(1).val(proptextures[i][1]);
    }
  }

  function UpdateTotals(drawTotal, propDrawTotal, textureTotal, headoverlayTotal, skinTotal) {
    for (var i = 0; i < Object.keys(drawTotal).length; i++) {
        if (drawTotal[i][0] == "hair") {
            $('.hair').each(function() {
                $(this).find('.total-number').eq(0).text(drawTotal[i][1]);
            })
        }
        $("#" + drawTotal[i][0]).parent().prev().text("Numara: " + drawTotal[i][1]);
        $("#" + drawTotal[i][0]).attr('max', drawTotal[i][1])
    }

    for (var i = 0; i < Object.keys(propDrawTotal).length; i++) {
        $("#" + propDrawTotal[i][0]).parent().prev().text("Numara: " + propDrawTotal[i][1]);
        $("#" + propDrawTotal[i][0]).attr('max', propDrawTotal[i][1])
    }

    for (const key of Object.keys(textureTotal)) {
        $("#" + key).attr('max', (textureTotal[key] - 1))
        $("#" + key).parent().prev().text("Numara :" + (textureTotal[key] - 1));
    }
  }

  function inputChange(input,inputType) {
    let nameId = $(input).attr("id").split("tex")[0]
    if($(input).attr("id").substr($(input).attr("id").length - 3) == "tex"){  //değiştirilcek texture ise
      $.post('http://wiro_clotheshop/updateclothes', JSON.stringify({
        "name": nameId,
        "value": $("#" + nameId).val(),
        "texture": $(input).val()
      })).done(function (data) {
        $("#" + $(input).attr("id") + "tex").parent().prev().text("Numara: " + data - 1);
        $("#" + $(input).attr("id") + "tex").attr('max', data - 1)
      });
    }
    else {  //değiştirilcek texture değil ise
      $.post('http://wiro_clotheshop/updateclothes', JSON.stringify({
        "name": nameId,
        "value": $(input).val(),
        "texture": 0
      })).done(function (data) {
        $("#" + $(input).attr("id") + "tex").parent().prev().text("Numara: " + String(data - 1));
        $("#" + $(input).attr("id") + "tex").val(0)
        $("#" + $(input).attr("id") + "tex").attr('max', data - 1)
      });
    }

  }

});
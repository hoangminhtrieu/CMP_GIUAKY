$(function () {
    $("#ReturnUrlHash").val(location.hash);
    var $form = $("#LoginForm");
    var $btn = $("#LoginButton");

    $form.on("submit", function (e) {
        e.preventDefault();

        var username = $("input[name='usernameOrEmailAddress']").val();
        var password = $("input[name='Password']").val();

        if (!username || !password) {
            if (typeof Swal !== 'undefined') {
                Swal.fire({
                    icon: 'warning',
                    title: 'Thông báo',
                    text: 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.'
                });
            } else {
                alert('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.');
            }
            return;
        }

        var origText = $btn.text();
        $btn.prop("disabled", true).text("Đang đăng nhập...");

        $.ajax({
            url: $form.attr("action") || "/Account/Login",
            type: "POST",
            data: $form.serialize(),
            success: function (res) {
                var targetUrl = "/Exam";
                if (res && res.result && res.result.targetUrl && res.result.targetUrl !== "/") {
                    targetUrl = res.result.targetUrl;
                } else if (res && res.targetUrl && res.targetUrl !== "/") {
                    targetUrl = res.targetUrl;
                }
                window.location.href = targetUrl;
            },
            error: function (xhr) {
                $btn.prop("disabled", false).text(origText);
                var errMsg = "Tên đăng nhập hoặc mật khẩu không chính xác.";
                if (xhr.responseJSON && xhr.responseJSON.error && xhr.responseJSON.error.message) {
                    errMsg = xhr.responseJSON.error.message;
                    if (xhr.responseJSON.error.details) {
                        errMsg += "\n" + xhr.responseJSON.error.details;
                    }
                }
                if (typeof Swal !== 'undefined') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Đăng nhập không thành công',
                        text: errMsg,
                        footer: '<small>Gợi ý tài khoản mẫu: <b>admin</b> / mật khẩu: <b>123qwe</b></small>'
                    });
                } else {
                    alert(errMsg + "\n(Gợi ý tài khoản mẫu: admin / 123qwe)");
                }
            }
        });
    });
});

# コマンドリファレンス

rspecでテスト
```bash
bundle exec rspec spec/以下パス
```

データベースの作成
```bash
bin/rails db:create
```

アプリ起動

```bash
bin/rails s -b 0.0.0.0
or
docker compose exec web bin/rails s -b 0.0.0.0
```

モデル生成
```bash
bin/rails g model StaffMember
```

migration実行
```bash
bin/rails db:migrate
# リセットする場合はこちら
bin/rails db:migrate:reset
```


